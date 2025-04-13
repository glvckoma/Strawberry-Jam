package game.trivia
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.graphics.LayerAnim;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class Trivia extends GameBase implements IMinigame
   {
      private static const MIN_PLAYERS:int = 2;
      
      private static const MAX_PLAYERS:int = 12;
      
      private static const ANSWER_DISPLAY_TIME:int = 2000;
      
      private static const DANCE_TIME:int = 0;
      
      private static const ROUND_TIME:int = 60;
      
      private static const WAITING_FOR_START_STATE:int = 0;
      
      private static const QUESTION_STATE:int = 1;
      
      private static const ANSWER_STATE:int = 2;
      
      private static const DANCE_STATE:int = 3;
      
      private static const WAITING_FOR_STATS_STATE:int = 4;
      
      private static const JOININPROGRESS_STATE:int = 5;
      
      private static const EMOT_DISPLAY_TIME:int = 3;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private var _myPlayerId:int;
      
      private var _mySfsId:int;
      
      private var _myScore:int = 0;
      
      private var _numPlayers:uint;
      
      private var _currentLeaderId:int;
      
      private var _players:Array;
      
      private var _playerSfsIds:Array;
      
      private var _playerPodiums:Array;
      
      private var _rowLookup:Array;
      
      private var _gemPayout:Array = [10,15,20,25,30,35,40,45,50,60,75,100];
      
      private var _playerStars:Array;
      
      private var _playerStreaks:Array;
      
      private var _playerAnimationLoops:Array;
      
      private var _totalGameTimer:Number;
      
      private var _gameTimer:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _displayAchievementTimer:Number;
      
      private var _countdownTime:Number;
      
      private var _tenDigitPrev:int;
      
      private var _oneDigitPrev:int;
      
      private var _bDancing:Boolean;
      
      private var _doneDancing:Boolean;
      
      private var _gameState:int = 0;
      
      private var _gemToBreak:int;
      
      private var _starTimer:Number;
      
      private var _statsTimer:Number;
      
      private var _nextRoundTimer:Number;
      
      private var _waitForNextRound:Boolean;
      
      private var _joinInProgress:Boolean;
      
      private var _joinInProgressTimer:Number;
      
      private var _qAndA:MovieClip;
      
      private var _bQAOpen:Boolean;
      
      private var _playerStarId:int;
      
      private var _question:String = "";
      
      private var _answer1:String = "";
      
      private var _answer2:String = "";
      
      private var _answer3:String = "";
      
      private var _myAnswer:int;
      
      private var _correctAnswer:int;
      
      private var _sendServerMyAnswer:Boolean = true;
      
      private var _timeoutCount:int;
      
      private var _background:Sprite;
      
      private var _playerLayer1:Sprite;
      
      private var _playerLayer2:Sprite;
      
      private var _playerLayer3:Sprite;
      
      private var _foreground:Sprite;
      
      private var _normalFormat:TextFormat;
      
      private var _selectedFormat:TextFormat;
      
      private var _bInit:Boolean;
      
      private var _offset:Point;
      
      private var _gameStarted:Boolean;
      
      private var _bNewState:Boolean;
      
      private var _canChooseAnswer:Boolean;
      
      private var _firstRoundForPlayer:Boolean;
      
      private var _newAvatarPId:Array = [];
      
      private var _newUserJoinedCount:int = 0;
      
      public var _soundMan:SoundManager;
      
      private const _audio:Array = ["trivia_check_mark.mp3","trivia_flame_off.mp3","trivia_flame_on.mp3","trivia_answer_select.mp3","trivia_fail.mp3","trivia_success.mp3","popup_results_enter.mp3","popup_results_exit.mp3","question_board_enter.mp3","question_board_exit.mp3","star_awarded.mp3","trivia_5_seconds_left.mp3","trivia_cheer.mp3","menu_exit_click.mp3","trivia_popup_next_round.mp3"];
      
      private var _soundNameCheckMark:String = _audio[0];
      
      private var _soundNameFlameOff:String = _audio[1];
      
      private var _soundNameFlameOn:String = _audio[2];
      
      private var _soundNameSelectAnswer:String = _audio[3];
      
      private var _soundNameFail:String = _audio[4];
      
      private var _soundNameSuccess:String = _audio[5];
      
      private var _soundNamePopupResultsEnter:String = _audio[6];
      
      private var _soundNamePopupResultsExit:String = _audio[7];
      
      private var _soundNameQuestionBoardEnter:String = _audio[8];
      
      private var _soundNameQuestionBoardExit:String = _audio[9];
      
      private var _soundNameStarAwarded:String = _audio[10];
      
      private var _soundName5SecondsLeft:String = _audio[11];
      
      private var _soundNameCheer:String = _audio[12];
      
      private var _soundNameAnswerRolloverMusic:String = _audio[13];
      
      private var _soundNamePopupNextRound:String = _audio[14];
      
      private var _timerSound:SoundChannel;
      
      private var _SFX_ThinkMusic:SBMusic;
      
      public function Trivia()
      {
         super();
      }
      
      private function loadSounds() : void
      {
         _SFX_ThinkMusic = _soundMan.addStream("trivia_mus_think",1.23);
         _soundMan.addSoundByName(_audioByName[_soundNameCheckMark],_soundNameCheckMark,1);
         _soundMan.addSoundByName(_audioByName[_soundNameFlameOff],_soundNameFlameOff,1);
         _soundMan.addSoundByName(_audioByName[_soundNameFlameOn],_soundNameFlameOn,1);
         _soundMan.addSoundByName(_audioByName[_soundNameSelectAnswer],_soundNameSelectAnswer,1);
         _soundMan.addSoundByName(_audioByName[_soundNameFail],_soundNameFail,1);
         _soundMan.addSoundByName(_audioByName[_soundNameSuccess],_soundNameSuccess,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupResultsEnter],_soundNamePopupResultsEnter,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupResultsExit],_soundNamePopupResultsExit,1);
         _soundMan.addSoundByName(_audioByName[_soundNameQuestionBoardEnter],_soundNameQuestionBoardEnter,1);
         _soundMan.addSoundByName(_audioByName[_soundNameQuestionBoardExit],_soundNameQuestionBoardExit,1);
         _soundMan.addSoundByName(_audioByName[_soundNameStarAwarded],_soundNameStarAwarded,1);
         _soundMan.addSoundByName(_audioByName[_soundName5SecondsLeft],_soundName5SecondsLeft,0.61);
         _soundMan.addSoundByName(_audioByName[_soundNameCheer],_soundNameCheer,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameAnswerRolloverMusic],_soundNameAnswerRolloverMusic,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupNextRound],_soundNamePopupNextRound,1);
      }
      
      public function msgCall() : void
      {
         trace("msgCall");
      }
      
      public function leaveCall() : void
      {
         trace("leaveCall");
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
            if(_numPlayers <= 0 || _numPlayers > 12)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            _players = new Array(12);
            _playerPodiums = new Array(12);
            _playerStars = [];
            _playerStreaks = [];
            _playerAnimationLoops = [];
            _rowLookup = new Array(12);
            _rowLookup["p1"] = 1;
            _rowLookup["p2"] = 1;
            _rowLookup["p3"] = 0;
            _rowLookup["p4"] = 0;
            _rowLookup["p5"] = 2;
            _rowLookup["p6"] = 2;
            _rowLookup["p7"] = 1;
            _rowLookup["p8"] = 1;
            _rowLookup["p9"] = 2;
            _rowLookup["p10"] = 2;
            _rowLookup["p11"] = 2;
            _rowLookup["p12"] = 2;
            _currentLeaderId = -1;
            _starTimer = 0;
            _statsTimer = 0;
            _nextRoundTimer = 0;
            _playerStarId = -1;
            _background = new Sprite();
            _playerLayer1 = new Sprite();
            _playerLayer2 = new Sprite();
            _playerLayer3 = new Sprite();
            _foreground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_playerLayer1);
            addChild(_playerLayer2);
            addChild(_playerLayer3);
            addChild(_foreground);
            addChild(_guiLayer);
            loadScene("TriviaAssets/game_main.xroom",_audio);
            _myAnswer = -1;
            _countdownTime = 60;
            _tenDigitPrev = -1;
            _oneDigitPrev = -1;
            _waitForNextRound = false;
            _joinInProgress = false;
            _joinInProgressTimer = 0;
            _timeoutCount = 0;
            setupTextFormats();
            resetAll();
            addListeners();
            _gameState = 0;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         _soundMan = new SoundManager(this);
         loadSounds();
         _totalGameTimer = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _offset = _scene.getOffset(stage);
         _offset.x = int(_offset.x);
         _offset.y = int(_offset.y);
         var _loc3_:Array = _scene.getActorList("ActorLayer");
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc5_.s.x = _loc5_.s.x - _offset.x;
            _loc5_.s.y -= _offset.y;
            if(String(_loc5_.name).charAt(0) != "p")
            {
               var _loc8_:* = _loc5_.layer;
               if(2 !== _loc8_)
               {
                  _background.addChild(_loc5_.s);
               }
               else
               {
                  _foreground.addChild(_loc5_.s);
               }
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 12)
         {
            _loc2_ = int(_rowLookup["p" + (_loc4_ + 1)]);
            _playerPodiums[_loc4_] = _scene.getLayer("p" + (_loc4_ + 1));
            if(_loc2_ == 0)
            {
               _playerLayer3.addChild(_playerPodiums[_loc4_].loader);
            }
            else if(_loc2_ == 1)
            {
               _playerLayer2.addChild(_playerPodiums[_loc4_].loader);
            }
            else
            {
               _playerLayer1.addChild(_playerPodiums[_loc4_].loader);
            }
            _loc4_++;
         }
         _qAndA = _scene.getLayer("qAndA").loader.content;
         if(_question && _answer1 && _answer2 && _answer3)
         {
            _qAndA.shrine.shrine.question.text = _question;
            _qAndA.shrine.shrine.answer1.text = _answer1;
            _qAndA.shrine.shrine.answer2.text = _answer2;
            _qAndA.shrine.shrine.answer3.text = _answer3;
         }
         _qAndA.shrine.shrine.btn1.addEventListener("mouseDown",answerMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.btn2.addEventListener("mouseDown",answerMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.btn3.addEventListener("mouseDown",answerMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.btn1.addEventListener("rollOver",answerRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.btn2.addEventListener("rollOver",answerRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.btn3.addEventListener("rollOver",answerRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.btn1.addEventListener("rollOut",answerRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.btn2.addEventListener("rollOut",answerRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.btn3.addEventListener("rollOut",answerRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.happyButton.addEventListener("mouseDown",emotMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.sadButton.addEventListener("mouseDown",emotMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.confusedButton.addEventListener("mouseDown",emotMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.madButton.addEventListener("mouseDown",emotMouseDownHandler,false,0,true);
         _qAndA.shrine.shrine.happyButton.addEventListener("mouseUp",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.sadButton.addEventListener("mouseUp",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.confusedButton.addEventListener("mouseUp",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.madButton.addEventListener("mouseUp",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.happyButton.addEventListener("rollOver",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.sadButton.addEventListener("rollOver",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.confusedButton.addEventListener("rollOver",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.madButton.addEventListener("rollOver",emotRollOverHandler,false,0,true);
         _qAndA.shrine.shrine.happyButton.addEventListener("rollOut",emotRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.sadButton.addEventListener("rollOut",emotRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.confusedButton.addEventListener("rollOut",emotRollOutHandler,false,0,true);
         _qAndA.shrine.shrine.madButton.addEventListener("rollOut",emotRollOutHandler,false,0,true);
         if(_waitForNextRound)
         {
            _gameStarted = true;
            _gameState = 4;
            _countdownTime += 10;
            _qAndA.popupOn("waiting");
         }
         else if(_joinInProgress)
         {
            _gameStarted = true;
            _gameState = 5;
            _joinInProgressTimer = 3;
            _qAndA.popupOn("join");
         }
         else
         {
            openQA();
         }
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         if(!_gameStarted)
         {
            _gameStarted = true;
            _gameState = 1;
         }
         _bNewState = true;
         for each(var _loc7_ in _players)
         {
            if(_loc7_)
            {
               _loc6_ = _loc7_.pId;
               positionAvatar(_loc6_);
               if(_loc6_ == _myPlayerId)
               {
                  _scene.getLayer("spotlights").loader.content.player(_loc6_ + 1);
               }
               if(_playerStars[_loc6_])
               {
                  _playerPodiums[_loc6_].loader.content.star.gotoAndPlay("sparkle");
               }
               if(_playerStreaks[_loc7_.pId] > 0)
               {
                  _scene.getLayer("spotlights").loader.content.spotlightOn(_loc6_ + 1);
               }
            }
         }
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc16_:int = 0;
         var _loc12_:int = 0;
         var _loc8_:String = null;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc13_:int = 0;
         var _loc17_:int = 0;
         var _loc10_:int = 0;
         var _loc14_:Function = null;
         var _loc11_:Boolean = false;
         var _loc9_:int = 0;
         var _loc7_:TextField = null;
         var _loc15_:TextFormat = null;
         var _loc4_:int = 0;
         if(param1[0] == "mm")
         {
            if(param1[2] == "uj")
            {
               _loc5_ = 3;
               _numPlayers = param1[_loc5_++];
               _loc3_ = 0;
               while(_loc3_ < _numPlayers)
               {
                  _loc16_ = int(param1[_loc5_++]);
                  _loc6_ = int(param1[_loc5_++]);
                  _loc12_ = int(param1[_loc5_++]);
                  _loc8_ = param1[_loc5_++];
                  if(!_players[_loc6_])
                  {
                     _players[_loc6_] = new TriviaPlayer();
                     _players[_loc6_].pId = _loc6_;
                     _players[_loc6_].dbId = _loc12_;
                     _players[_loc6_].sfsId = _loc16_;
                     _players[_loc6_].userName = _loc8_;
                  }
                  _loc3_++;
               }
               _newUserJoinedCount++;
               setupAvatars();
            }
            else if(param1[2] == "se")
            {
               if(_gameStarted)
               {
                  _loc5_ = 3;
                  _loc6_ = int(param1[_loc5_++]);
                  _loc2_ = int(param1[_loc5_++]);
                  switch(_loc2_)
                  {
                     case 0:
                        _playerPodiums[_loc6_].loader.content.changeEmote("happy",3);
                        break;
                     case 1:
                        _playerPodiums[_loc6_].loader.content.changeEmote("sad",3);
                        break;
                     case 2:
                        _playerPodiums[_loc6_].loader.content.changeEmote("confused",3);
                        break;
                     case 3:
                        _playerPodiums[_loc6_].loader.content.changeEmote("mad",3);
                  }
               }
            }
            else if(param1[2] != "gb")
            {
               if(param1[2] == "ua")
               {
                  if(_gameStarted)
                  {
                     _loc5_ = 3;
                     _loc13_ = int(param1[_loc5_++]);
                     _loc17_ = int(param1[_loc5_++]);
                     _loc10_ = int(param1[_loc5_++]);
                     if(_currentLeaderId != _loc10_ && _playerPodiums[_currentLeaderId])
                     {
                        if(_currentLeaderId >= 0)
                        {
                           _playerPodiums[_currentLeaderId].loader.content.flameOff();
                        }
                        _currentLeaderId = _loc10_;
                        _playerPodiums[_currentLeaderId].loader.content.flameOn();
                        _soundMan.playByName(_soundNameFlameOn);
                     }
                     switch(_loc13_)
                     {
                        case 0:
                           _scene.getLayer("spotlights").loader.content.spotlightOff(_loc17_ + 1);
                           _players[_loc17_].avtView.playAnim(14,_loc17_ % 2 != 0);
                           break;
                        case 1:
                           _scene.getLayer("spotlights").loader.content.spotlightOn(_loc17_ + 1);
                           break;
                        case 2:
                           _qAndA.confetti(_loc17_ + 1);
                           break;
                        default:
                           _qAndA.confetti(_loc17_ + 1);
                           switch(_loc17_)
                           {
                              case 0:
                                 _loc14_ = player0AnimationCallback;
                                 break;
                              case 1:
                                 _loc14_ = player1AnimationCallback;
                                 break;
                              case 2:
                                 _loc14_ = player2AnimationCallback;
                                 break;
                              case 3:
                                 _loc14_ = player3AnimationCallback;
                                 break;
                              case 4:
                                 _loc14_ = player4AnimationCallback;
                                 break;
                              case 5:
                                 _loc14_ = player5AnimationCallback;
                                 break;
                              case 6:
                                 _loc14_ = player6AnimationCallback;
                                 break;
                              case 7:
                                 _loc14_ = player7AnimationCallback;
                                 break;
                              case 8:
                                 _loc14_ = player8AnimationCallback;
                                 break;
                              case 9:
                                 _loc14_ = player9AnimationCallback;
                                 break;
                              case 10:
                                 _loc14_ = player10AnimationCallback;
                                 break;
                              case 11:
                                 _loc14_ = player11AnimationCallback;
                           }
                           if(Math.random() < 0.5)
                           {
                              _players[_loc17_].avtView.playAnim(23,Boolean(_loc17_ % 2),0,_loc14_);
                              break;
                           }
                           _players[_loc17_].avtView.playAnim(17,Boolean(_loc17_ % 2),0,_loc14_);
                           break;
                     }
                  }
               }
               else if(param1[2] == "us")
               {
                  if(_totalGameTimer > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
                  }
                  _timeoutCount++;
                  if(_timeoutCount > 5)
                  {
                     exit();
                  }
                  else if(_gameStarted)
                  {
                     _loc5_ = 3;
                     if(param1[_loc5_].charAt(0) == "#")
                     {
                        _loc17_ = int(param1[_loc5_].replace("#",""));
                     }
                     else
                     {
                        _loc17_ = int(param1[_loc5_]);
                     }
                     _qAndA.starOn();
                     _playerStarId = _loc17_;
                     if(!_waitForNextRound)
                     {
                        _statsTimer = 2;
                        _nextRoundTimer = 3;
                     }
                     _starTimer = 2;
                     while(_loc5_ < param1.length)
                     {
                        if(param1[_loc5_].charAt(0) == "#")
                        {
                           _loc11_ = true;
                           param1[_loc5_] = param1[_loc5_].replace("#","");
                        }
                        else
                        {
                           _loc11_ = false;
                        }
                        _loc17_ = int(param1[_loc5_++]);
                        if(_loc17_ >= 0)
                        {
                           _loc9_ = int(_gemPayout[param1.length - _loc5_]);
                           _qAndA.resultsPopup.resultsPopup["results_" + (_loc5_ - 3)].text = String(_loc5_ - 3) + ". " + LocalizationManager.translateAvatarName(_players[_loc17_].avtView.avName);
                           if(_loc17_ == _myPlayerId)
                           {
                              _loc7_ = _qAndA.resultsPopup.resultsPopup["results_" + (_loc5_ - 3)];
                              _loc15_ = _loc7_.defaultTextFormat;
                              _loc15_.color = 3381555;
                              _loc7_.setTextFormat(_loc15_);
                              _loc7_ = _qAndA.resultsPopup.resultsPopup["gems_" + (_loc5_ - 3)];
                              _loc15_ = _loc7_.defaultTextFormat;
                              _loc15_.color = 3381555;
                              _loc7_.setTextFormat(_loc15_);
                              if(_loc11_ == false)
                              {
                                 addGemsToBalance(_loc9_);
                              }
                           }
                           LocalizationManager.translateIdAndInsert(_qAndA.resultsPopup.resultsPopup["gems_" + (_loc5_ - 3)],11097,_loc11_ ? 0 : _loc9_);
                        }
                     }
                     _loc5_++;
                     while(_loc5_ <= 3 + 12)
                     {
                        _qAndA.resultsPopup.resultsPopup["results_" + (_loc5_ - 3)].text = "";
                        _qAndA.resultsPopup.resultsPopup["gems_" + (_loc5_ - 3)].text = "";
                        _loc5_++;
                     }
                  }
               }
               else if(param1[2] == "sr")
               {
                  if(_gameStarted)
                  {
                     if(_currentLeaderId >= 0)
                     {
                        _playerPodiums[_currentLeaderId].loader.content.flameOff();
                        _currentLeaderId = -1;
                     }
                     for each(var _loc18_ in _players)
                     {
                        if(_loc18_)
                        {
                           _loc18_.avtView.playAnim(14,_loc18_.pId % 2 != 0);
                           _scene.getLayer("spotlights").loader.content.spotlightOff(_loc18_.pId + 1);
                        }
                     }
                     if(_waitForNextRound)
                     {
                        _qAndA.popupOff();
                     }
                     _gameState = 1;
                     _bNewState = true;
                     _countdownTime = 60;
                     _waitForNextRound = false;
                  }
               }
               else if(_gameStarted)
               {
                  _loc5_ = 2;
                  _loc13_ = int(param1[_loc5_++]);
                  _loc10_ = int(param1[_loc5_++]);
                  if(_currentLeaderId != _loc10_)
                  {
                     if(_currentLeaderId >= 0)
                     {
                        _playerPodiums[_currentLeaderId].loader.content.flameOff();
                     }
                     _currentLeaderId = _loc10_;
                     _playerPodiums[_currentLeaderId].loader.content.flameOn();
                     _soundMan.playByName(_soundNameFlameOn);
                  }
                  _question = param1[_loc5_++];
                  _answer1 = param1[_loc5_++];
                  _answer2 = param1[_loc5_++];
                  _answer3 = param1[_loc5_++];
                  _correctAnswer = param1[_loc5_++];
                  _firstRoundForPlayer = _correctAnswer == 0;
                  if(_loc13_ > 0)
                  {
                     if(!_firstRoundForPlayer)
                     {
                        _qAndA.shrine.shrine["check" + _myAnswer].x = _qAndA.shrine.shrine["answer" + _myAnswer].x + 0.5 * _qAndA.shrine.shrine["answer" + _myAnswer].width + 0.5 * _qAndA.shrine.shrine["answer" + _myAnswer].textWidth + 10;
                        _qAndA.shrine.shrine["check" + _myAnswer].gotoAndPlay("on");
                        _soundMan.playByName(_soundNameSuccess);
                        switch(_loc13_ - 1)
                        {
                           case 0:
                              _scene.getLayer("spotlights").loader.content.spotlightOn(_myPlayerId + 1);
                              break;
                           case 1:
                              _soundMan.playByName(_soundNameCheer);
                              _qAndA.confetti(_myPlayerId + 1);
                              break;
                           default:
                              _soundMan.playByName(_soundNameCheer);
                              _qAndA.confetti(_myPlayerId + 1);
                              switch(_myPlayerId)
                              {
                                 case 0:
                                    _loc14_ = player0AnimationCallback;
                                    break;
                                 case 1:
                                    _loc14_ = player1AnimationCallback;
                                    break;
                                 case 2:
                                    _loc14_ = player2AnimationCallback;
                                    break;
                                 case 3:
                                    _loc14_ = player3AnimationCallback;
                                    break;
                                 case 4:
                                    _loc14_ = player4AnimationCallback;
                                    break;
                                 case 5:
                                    _loc14_ = player5AnimationCallback;
                                    break;
                                 case 6:
                                    _loc14_ = player6AnimationCallback;
                                    break;
                                 case 7:
                                    _loc14_ = player7AnimationCallback;
                                    break;
                                 case 8:
                                    _loc14_ = player8AnimationCallback;
                                    break;
                                 case 9:
                                    _loc14_ = player9AnimationCallback;
                                    break;
                                 case 10:
                                    _loc14_ = player10AnimationCallback;
                                    break;
                                 case 11:
                                    _loc14_ = player11AnimationCallback;
                              }
                              if(Math.random() < 0.5)
                              {
                                 _players[_myPlayerId].avtView.playAnim(23,Boolean(_myPlayerId % 2),0,_loc14_);
                                 break;
                              }
                              _players[_myPlayerId].avtView.playAnim(17,Boolean(_myPlayerId % 2),0,_loc14_);
                              break;
                        }
                     }
                  }
                  else if(!_firstRoundForPlayer)
                  {
                     _qAndA.shrine.shrine["check" + _correctAnswer].x = _qAndA.shrine.shrine["answer" + _correctAnswer].x + 0.5 * _qAndA.shrine.shrine["answer" + _correctAnswer].width + 0.5 * _qAndA.shrine.shrine["answer" + _correctAnswer].textWidth + 10;
                     _qAndA.shrine.shrine["check" + _correctAnswer].gotoAndPlay("on");
                     if(_myAnswer != -1)
                     {
                        _qAndA.shrine.shrine["x" + _myAnswer].gotoAndPlay("on");
                     }
                     _scene.getLayer("spotlights").loader.content.spotlightOff(_myPlayerId + 1);
                     _players[_myPlayerId].avtView.playAnim(14,_myPlayerId % 2 != 0);
                  }
                  _gemToBreak = 1;
                  _gameTimer = getTimer();
                  _bNewState = true;
                  _gameState = 2;
               }
            }
         }
         else if(param1[0] != "mj")
         {
            if(param1[0] == "ml")
            {
               if(_gameStarted)
               {
                  _loc6_ = int(param1[2]);
                  _players[_loc6_].avtView.parent.removeChild(_players[_loc6_].avtView);
                  _players[_loc6_].destroy();
                  _players[_loc6_] = null;
                  if(_currentLeaderId == _loc6_)
                  {
                     _playerPodiums[_currentLeaderId].loader.content.flameOff();
                     _currentLeaderId = -1;
                  }
                  if(_playerStarId == _loc6_)
                  {
                     _playerStarId = -1;
                  }
                  _scene.getLayer("spotlights").loader.content.spotlightOff(_loc6_ + 1);
                  _playerPodiums[_loc6_].loader.content.starOff();
                  _numPlayers--;
               }
            }
            else if(param1[0] == "ms")
            {
               _loc5_ = 1;
               _loc4_ = 0;
               _loc4_ = 0;
               while(_loc4_ < _numPlayers)
               {
                  _loc6_ = int(param1[_loc5_++]);
                  _players[_loc6_] = new TriviaPlayer();
                  _players[_loc6_].pId = _loc6_;
                  _players[_loc6_].dbId = param1[_loc5_++];
                  _players[_loc6_].sfsId = _playerSfsIds[_loc4_];
                  if(_players[_loc6_].sfsId == _mySfsId)
                  {
                     _myPlayerId = _players[_loc6_].pId;
                  }
                  _playerStars[_loc6_] = int(param1[_loc5_++]);
                  _playerStreaks[_loc6_] = int(param1[_loc5_++]);
                  _players[_loc6_].userName = param1[_loc5_++];
                  if(_gameStarted)
                  {
                     if(_playerStars[_loc6_])
                     {
                        _playerPodiums[_loc6_].loader.content.star.gotoAndPlay("sparkle");
                     }
                     if(_playerStreaks[_loc6_] > 0)
                     {
                        _scene.getLayer("spotlights").loader.content.spotlightOn(_loc6_ + 1);
                     }
                  }
                  _loc4_++;
               }
               _countdownTime = param1[_loc5_++];
               _countdownTime = 60 - _countdownTime;
               if(_countdownTime < 7)
               {
                  _waitForNextRound = true;
                  if(_gameStarted)
                  {
                     closeQA();
                     _gameState = 4;
                     _countdownTime += 10;
                     _qAndA.popupOn("waiting");
                  }
               }
               else if(_numPlayers > 1)
               {
                  _joinInProgress = true;
                  if(_gameStarted)
                  {
                     closeQA();
                     _gameState = 5;
                     _joinInProgressTimer = 3;
                     _qAndA.popupOn("join");
                  }
               }
               _question = param1[_loc5_++];
               _answer1 = param1[_loc5_++];
               _answer2 = param1[_loc5_++];
               _answer3 = param1[_loc5_];
               setupAvatars();
               _gemToBreak = 1;
            }
         }
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function setupAvatars() : void
      {
         var _loc2_:Avatar = null;
         var _loc1_:UserInfo = null;
         for each(var _loc3_ in _players)
         {
            if(_loc3_)
            {
               if(!_loc3_.avtView)
               {
                  if(_newUserJoinedCount > 0)
                  {
                     _newAvatarPId.push(_loc3_.pId);
                  }
                  _loc2_ = new Avatar();
                  _loc2_.init(_loc3_.dbId,-1,"triviaAvt" + _loc3_.dbId,1,[0,0,0],-1,null,_loc3_.userName);
                  AvatarXtCommManager.requestADForAvatar(_loc3_.dbId,true,avatarAdCallback,_loc2_);
                  if(_loc3_.userName == gMainFrame.userInfo.myUserName)
                  {
                     _loc1_ = gMainFrame.userInfo.playerUserInfo;
                     if(_loc1_)
                     {
                        _loc2_.itemResponseIntegrate(_loc1_.getFullItemList(true));
                     }
                  }
                  _loc3_.avtView = new AvatarView();
                  _loc3_.avtView.init(_loc2_);
               }
            }
         }
      }
      
      private function openQA() : void
      {
         if(!_bQAOpen)
         {
            _bQAOpen = true;
            _qAndA.shrineUp();
            _soundMan.playByName(_soundNameQuestionBoardEnter);
            if(!_qAndA.newRound.ready)
            {
               _qAndA.newRound.gotoAndPlay("off");
            }
            if(_statsTimer <= 0)
            {
               if(_starTimer > 0)
               {
                  _qAndA.resultsOff();
                  _soundMan.playByName(_soundNamePopupResultsExit);
                  if(_playerStarId >= 0)
                  {
                     _playerPodiums[_playerStarId].loader.content.starOn();
                  }
                  _soundMan.playByName(_soundNameStarAwarded);
               }
               else if(_nextRoundTimer > 0)
               {
                  _qAndA.resultsOff();
                  _soundMan.playByName(_soundNamePopupResultsExit);
               }
            }
            _statsTimer = _starTimer = _nextRoundTimer = 0;
         }
      }
      
      private function closeQA() : void
      {
         if(_bQAOpen)
         {
            _bQAOpen = false;
            _qAndA.shrineDown();
            _soundMan.playByName(_soundNameQuestionBoardExit);
            if(_timerSound)
            {
               _timerSound.stop();
            }
         }
      }
      
      private function avatarAdCallback(param1:String = null) : void
      {
         if(_newUserJoinedCount > 0)
         {
            positionAvatar(_newAvatarPId[0]);
            _newAvatarPId.shift();
            _newUserJoinedCount--;
         }
      }
      
      private function endCleanup() : void
      {
         removeListeners();
         if(_timerSound)
         {
            _timerSound.stop();
            _timerSound = null;
         }
         for each(var _loc1_ in _players)
         {
            if(_loc1_)
            {
               if(_loc1_.avtView && _loc1_.avtView.parent)
               {
                  _loc1_.avtView.parent.removeChild(_loc1_.avtView);
                  _loc1_.avtView.destroy();
               }
               _loc1_.avtView = null;
               _players.splice(_loc1_.pId,1);
            }
         }
         resetAll();
      }
      
      public function resetAll() : void
      {
         _gameState = 0;
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
      
      private function positionAvatar(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         if(!_gameStarted)
         {
            return;
         }
         var _loc4_:int = 20;
         _players[param1].avtView.playAnim(14,param1 % 2 != 0);
         if(param1 % 2 != 0)
         {
            _loc4_ += _playerPodiums[param1].width;
         }
         _players[param1].avtView.x = _playerPodiums[param1].x + _loc4_;
         _players[param1].avtView.y = _playerPodiums[param1].y + 60;
         switch(_rowLookup["p" + (param1 + 1)])
         {
            case 0:
               _playerLayer3.addChildAt(_players[param1].avtView,0);
               break;
            case 1:
               _playerLayer2.addChildAt(_players[param1].avtView,0);
               break;
            case 2:
               _playerLayer1.addChildAt(_players[param1].avtView,0);
         }
         switch(_players[param1].avtView.avatarData.avTypeId)
         {
            case 1:
               _loc3_ = -5;
               _loc5_ = -30;
               break;
            case 4:
               _loc3_ = -5;
               _loc5_ = -45;
               break;
            case 5:
               _loc3_ = -5;
               _loc5_ = -45;
               break;
            case 6:
               _loc3_ = -5;
               _loc5_ = -50;
               break;
            case 7:
               _loc3_ = -5;
               _loc5_ = -50;
               break;
            case 8:
               _loc3_ = -5;
               _loc5_ = -50;
               break;
            case 10:
               _loc3_ = 0;
               _loc5_ = -40;
               break;
            default:
               _loc3_ = -5;
               _loc5_ = -45;
         }
         _playerPodiums[param1].loader.content.emoticon.x = _loc3_ + (param1 % 2 == 0 ? -32 : 32);
         _playerPodiums[param1].loader.content.emoticon.y = _loc5_ - 49;
      }
      
      private function addListeners() : void
      {
         addEventListener("enterFrame",enterFrameHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         removeEventListener("enterFrame",enterFrameHandler);
         _qAndA.shrine.shrine.btn1.removeEventListener("mouseDown",answerMouseDownHandler);
         _qAndA.shrine.shrine.btn2.removeEventListener("mouseDown",answerMouseDownHandler);
         _qAndA.shrine.shrine.btn3.removeEventListener("mouseDown",answerMouseDownHandler);
      }
      
      private function answerMouseDownHandler(param1:MouseEvent) : void
      {
         if(_myAnswer == -1 && _canChooseAnswer)
         {
            switch(param1.currentTarget.name)
            {
               case "btn1":
                  _myAnswer = 1;
                  _qAndA.shrine.shrine.answer1.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(1);
                  break;
               case "btn2":
                  _myAnswer = 2;
                  _qAndA.shrine.shrine.answer2.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(2);
                  break;
               case "btn3":
                  _myAnswer = 3;
                  _qAndA.shrine.shrine.answer3.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(3);
            }
            _soundMan.playByName(_soundNameSelectAnswer);
            messageServerIfNotSpamming();
            _qAndA.shrine.shrine.btn1.mouseEnabled = false;
         }
      }
      
      private function answerRollOverHandler(param1:MouseEvent) : void
      {
         if(_myAnswer == -1 && _canChooseAnswer)
         {
            _soundMan.playByName(_soundNameAnswerRolloverMusic);
            switch(param1.currentTarget.name)
            {
               case "btn1":
                  _qAndA.shrine.shrine.answer1.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(1);
                  break;
               case "btn2":
                  _qAndA.shrine.shrine.answer2.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(2);
                  break;
               case "btn3":
                  _qAndA.shrine.shrine.answer3.setTextFormat(_selectedFormat);
                  _qAndA.backlightOn(3);
            }
         }
      }
      
      private function answerRollOutHandler(param1:MouseEvent) : void
      {
         if(_myAnswer == -1 && _canChooseAnswer)
         {
            switch(param1.currentTarget.name)
            {
               case "btn1":
                  _qAndA.shrine.shrine.answer1.setTextFormat(_normalFormat);
                  _qAndA.backlightOff(1);
                  break;
               case "btn2":
                  _qAndA.shrine.shrine.answer2.setTextFormat(_normalFormat);
                  _qAndA.backlightOff(2);
                  break;
               case "btn3":
                  _qAndA.shrine.shrine.answer3.setTextFormat(_normalFormat);
                  _qAndA.backlightOff(3);
            }
         }
      }
      
      private function emotMouseDownHandler(param1:MouseEvent) : void
      {
         _timeoutCount = 0;
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _playerPodiums[_myPlayerId].loader.content.changeEmote("happy",3);
               _qAndA.buttonPress("happy");
               MinigameManager.msg(["se",0]);
               break;
            case "sadButton":
               _playerPodiums[_myPlayerId].loader.content.changeEmote("sad",3);
               _qAndA.buttonPress("sad");
               MinigameManager.msg(["se",1]);
               break;
            case "confusedButton":
               _playerPodiums[_myPlayerId].loader.content.changeEmote("confused",3);
               _qAndA.buttonPress("confused");
               MinigameManager.msg(["se",2]);
               break;
            case "madButton":
               _playerPodiums[_myPlayerId].loader.content.changeEmote("mad",3);
               _qAndA.buttonPress("mad");
               MinigameManager.msg(["se",3]);
         }
      }
      
      private function emotRollOverHandler(param1:MouseEvent) : void
      {
         _soundMan.playByName(_soundNameAnswerRolloverMusic);
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _qAndA.buttonRollover("happy");
               break;
            case "sadButton":
               _qAndA.buttonRollover("sad");
               break;
            case "confusedButton":
               _qAndA.buttonRollover("confused");
               break;
            case "madButton":
               _qAndA.buttonRollover("mad");
         }
      }
      
      private function emotRollOutHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _qAndA.buttonIdle("happy");
               break;
            case "sadButton":
               _qAndA.buttonIdle("sad");
               break;
            case "confusedButton":
               _qAndA.buttonIdle("confused");
               break;
            case "madButton":
               _qAndA.buttonIdle("mad");
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
      
      private function player0AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,0);
      }
      
      private function player1AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,1);
      }
      
      private function player2AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,2);
      }
      
      private function player3AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,3);
      }
      
      private function player4AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,4);
      }
      
      private function player5AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,5);
      }
      
      private function player6AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,6);
      }
      
      private function player7AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,7);
      }
      
      private function player8AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,8);
      }
      
      private function player9AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,9);
      }
      
      private function player10AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,10);
      }
      
      private function player11AnimationCallback(param1:LayerAnim, param2:int) : void
      {
         playerAnimationCallback(param1,param2,11);
      }
      
      private function playerAnimationCallback(param1:LayerAnim, param2:int, param3:int) : void
      {
         if(_players[param3] && _players[param3].avtView && param1)
         {
            if(_playerAnimationLoops[param3])
            {
               _playerAnimationLoops[param3]++;
               if(_playerAnimationLoops[param3] >= 3)
               {
                  _playerAnimationLoops[param3] = 0;
                  _players[param3].avtView.playAnim(14,Boolean(param3 % 2));
               }
            }
            else
            {
               _playerAnimationLoops[param3] = 1;
            }
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
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
               _qAndA.resultsOn();
               _soundMan.playByName(_soundNamePopupResultsEnter);
               _qAndA.popupSize("large");
            }
         }
         else if(_starTimer > 0)
         {
            _starTimer -= _frameTime;
            if(_starTimer <= 0 && _playerStarId >= 0)
            {
               _qAndA.starReward(_playerStarId + 1);
               _playerPodiums[_playerStarId].loader.content.starOn();
               _soundMan.playByName(_soundNameStarAwarded);
               if(_playerStarId == _myPlayerId)
               {
                  MinigameManager.msg(["_a",3]);
                  if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
                     _displayAchievementTimer = 1;
                  }
               }
            }
         }
         else if(_nextRoundTimer > 0)
         {
            _nextRoundTimer -= _frameTime;
            if(_nextRoundTimer <= 0)
            {
               _qAndA.resultsOff();
               _soundMan.playByName(_soundNamePopupResultsExit);
               _soundMan.playByName(_soundNamePopupNextRound);
               _qAndA.newRound.gotoAndPlay("on");
            }
         }
         _lastTime = getTimer();
         if(_gameState > 0)
         {
            _countdownTime -= _frameTime;
            if(_countdownTime <= 0)
            {
               _countdownTime = 0;
               if(_gameState != 4)
               {
                  MinigameManager.msg(["te"]);
                  _gameState = 4;
                  _bNewState = true;
                  closeQA();
               }
            }
            else if(_countdownTime < 5 && Math.floor(_countdownTime) != Math.floor(_countdownTime + _frameTime))
            {
               _soundMan.playByName(_soundName5SecondsLeft);
            }
            _qAndA.updateTimer(Math.floor((60 - _countdownTime) / 60 * 999 + 1));
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
               if(_bNewState)
               {
                  LocalizationManager.translateId(_qAndA.shrine.shrine.question,parseInt(_question));
                  LocalizationManager.translateId(_qAndA.shrine.shrine.answer1,parseInt(_answer1));
                  LocalizationManager.translateId(_qAndA.shrine.shrine.answer2,parseInt(_answer2));
                  LocalizationManager.translateId(_qAndA.shrine.shrine.answer3,parseInt(_answer3));
                  _qAndA.shrine.shrine.answer1.setTextFormat(_normalFormat);
                  _qAndA.shrine.shrine.answer2.setTextFormat(_normalFormat);
                  _qAndA.shrine.shrine.answer3.setTextFormat(_normalFormat);
                  if(_myAnswer != -1)
                  {
                     _qAndA.shrine.shrine["x" + _myAnswer].gotoAndPlay("off");
                  }
                  _qAndA.shrine.shrine["check1"].gotoAndPlay("off");
                  _qAndA.shrine.shrine["check2"].gotoAndPlay("off");
                  _qAndA.shrine.shrine["check3"].gotoAndPlay("off");
                  _myAnswer = -1;
                  _qAndA.backlightOff(1);
                  _qAndA.backlightOff(2);
                  _qAndA.backlightOff(3);
                  _bNewState = false;
                  if(!_bQAOpen)
                  {
                     openQA();
                  }
                  _canChooseAnswer = true;
                  if(_timerSound)
                  {
                     _timerSound.stop();
                     _timerSound = null;
                  }
                  _timerSound = _soundMan.playStream(_SFX_ThinkMusic,0,10);
               }
               break;
            case 2:
               if(_bNewState)
               {
                  _canChooseAnswer = false;
                  _bNewState = false;
                  if(_timerSound)
                  {
                     _timerSound.stop();
                  }
               }
               _qAndA.shrine.shrine.btn1.mouseEnabled = true;
               if(_gameTimer + 2000 - getTimer() < 0)
               {
                  _bNewState = true;
                  _gameState = 3;
                  _gameTimer = getTimer();
               }
               break;
            case 3:
               if(_bNewState)
               {
                  _doneDancing = false;
                  _bNewState = false;
               }
               if(!_bDancing && !_doneDancing && _gameTimer + 0 - (0 - 500) - getTimer() < 0)
               {
                  for each(_loc2_ in _players)
                  {
                     if(_loc2_)
                     {
                        if(_loc2_.bCorrect)
                        {
                           _players[_loc2_.pId].avtView.playAnim(23);
                           if(_loc2_.pId == _myPlayerId)
                           {
                              _soundMan.playByName(_soundNameSuccess);
                           }
                        }
                        else if(_loc2_.pId == _myPlayerId)
                        {
                           _soundMan.playByName(_soundNameFail);
                        }
                     }
                  }
                  _bDancing = true;
               }
               if(_bDancing && _gameTimer + 0 - 1500 - getTimer() < 0)
               {
                  for each(_loc2_ in _players)
                  {
                     if(_loc2_)
                     {
                        _loc2_.avtView.playAnim(14,Boolean(_loc2_.pId % 2));
                     }
                  }
                  _bDancing = false;
                  _doneDancing = true;
               }
               if(!_bDancing && _gameTimer + 0 - getTimer() < 0)
               {
                  _bNewState = true;
                  _gameState = 1;
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
                  _qAndA.roundJoin.roundJoin.timerText.text = Math.floor(_countdownTime);
               }
               break;
            case 5:
               if(_joinInProgressTimer > 0)
               {
                  _joinInProgressTimer -= _frameTime;
                  if(_joinInProgressTimer <= 0)
                  {
                     _qAndA.popupOff();
                     _joinInProgressTimer = 0;
                     _joinInProgress = false;
                     _gameState = 1;
                     _bNewState = true;
                  }
               }
               break;
            default:
               throw new Error("ERROR: invalid state in trivia game!");
         }
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
      
      private function showGameOverDlg() : void
      {
      }
      
      private function GameOverDlg_close() : void
      {
      }
   }
}

