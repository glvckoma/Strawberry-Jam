package game.safetyQuiz
{
   import achievement.AchievementXtCommManager;
   import com.sbi.popup.SBPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import giftPopup.GiftPopup;
   import localization.LocalizationManager;
   
   public class SafetyQuiz extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _mainPopup:MovieClip;
      
      private var _shuffler:Array = [0,1,2];
      
      private var _questionIndex:int = 0;
      
      private var _questionsCorrect:int = 0;
      
      private var _currentSelection:int;
      
      private var _nextQuestionTimer:Number = 0;
      
      private var _prizeDenItems:DenItem;
      
      private var _prizePopup:GiftPopup;
      
      private var _serialNumber:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _gemsAwarded:int;
      
      private var _qAndAs:Array = [{
         "q":11825,
         "a":[11826,11827,11828]
      },{
         "q":11829,
         "a":[11830,11831,11832]
      },{
         "q":11833,
         "a":[11834,11835,11836]
      },{
         "q":11837,
         "a":[11838,11839,11840]
      },{
         "q":11841,
         "a":[11842,11843,11844]
      },{
         "q":11845,
         "a":[11846,11847,11848]
      },{
         "q":11849,
         "a":[11850,11851,11852]
      },{
         "q":11853,
         "a":[11854,11855,11856]
      },{
         "q":11857,
         "a":[11858,11859,11860]
      },{
         "q":11861,
         "a":[11862,11863,11864]
      }];
      
      private var _soundMan:SoundManager;
      
      private const _audio:Array = ["hud_exitRollover.mp3","hud_exitSelect.mp3"];
      
      private var _soundNameHudExitRollover:String = _audio[0];
      
      private var _soundNameHudExitSelect:String = _audio[1];
      
      public function SafetyQuiz()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameHudExitRollover],_soundNameHudExitRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameHudExitSelect],_soundNameHudExitSelect,0.3);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         MinigameManager.msg(["hs"]);
         init();
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
      
      public function end(param1:Array) : void
      {
         stage.removeEventListener("enterFrame",heartbeat);
         _mainPopup.removeEventListener("click",checkClick);
         _mainPopup.answer3.voteBtn.removeEventListener("mouseDown",onSubmitBtnDown);
         _mainPopup.answer3.voteBtn.removeEventListener("mouseOver",onSubmitBtnOver);
         _mainPopup.answer3.voteBtn.removeEventListener("mouseOut",onSubmitBtnOut);
         _mainPopup.rulesBtn.removeEventListener("mouseDown",onRulesDown);
         releaseBase();
         _bInit = false;
         removeLayer(_guiLayer);
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _guiLayer = new Sprite();
            addChild(_guiLayer);
            loadScene("SafetyQuizAssets/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         _soundMan = new SoundManager(this);
         loadSounds();
         _sceneLoaded = true;
         _prizeDenItems = new DenItem();
         _prizeDenItems.initShopItem(1179,0);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         _mainPopup = GETDEFINITIONBYNAME("SafetyQuizPollPopup");
         _guiLayer.addChild(_mainPopup);
         _mainPopup.addEventListener("click",checkClick,false,0,true);
         _closeBtn = addBtn("CloseButton",657,107,onExit);
         _mainPopup.answer3.voteBtn.mouseChildren = false;
         _mainPopup.answer3.voteBtn.addEventListener("mouseDown",onSubmitBtnDown,false,0,true);
         _mainPopup.answer3.voteBtn.addEventListener("mouseOver",onSubmitBtnOver,false,0,true);
         _mainPopup.answer3.voteBtn.addEventListener("mouseOut",onSubmitBtnOut,false,0,true);
         _mainPopup.rulesBtn.addEventListener("mouseDown",onRulesDown,false,0,true);
         _mainPopup.resultsTxt.visible = false;
         _mainPopup.answer3.voteBtn.mouse.visible = false;
         _mainPopup.answer3.voteBtn.down.visible = false;
         _mainPopup.answer3.correct.visible = false;
         _mainPopup.answer3.wrong.visible = false;
         LocalizationManager.translateId(_mainPopup.titleTxt,11824);
         startGame();
         randomizeArray(_qAndAs);
         nextQuestion();
         super.sceneLoaded(param1);
      }
      
      private function onRulesDown(param1:MouseEvent) : void
      {
         new SBPopup(_guiLayer,GETDEFINITIONBYNAME("ReportRulesPopupSkin"),GETDEFINITIONBYNAME("ReportRulesPopupContent"),true,true,false,false);
      }
      
      private function awardGift() : void
      {
         _prizePopup = new GiftPopup();
         _prizePopup.init(this.parent,_prizeDenItems.icon,_prizeDenItems.name,_prizeDenItems.defId,2,2,keptItem,rejectedItem,destroyPrizePopup);
      }
      
      private function keptItem() : void
      {
         var _loc1_:Number = (gMainFrame.server.userId + 99) * 3 + (_serialNumber + 49) * 5;
         var _loc2_:Number = (_serialNumber + gMainFrame.server.userId) * 3;
         MinigameManager.msg(["hp",_loc1_,_loc2_]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         _prizePopup.close();
         AchievementXtCommManager.requestSetUserVar(364,1);
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      private function onSubmitBtnOver(param1:MouseEvent) : void
      {
         if(_mainPopup.answer3.voteBtn.mouse.visible)
         {
            _mainPopup.answer3.voteBtn.mouse.play();
            _soundMan.playByName(_soundNameHudExitRollover);
         }
      }
      
      private function onSubmitBtnOut(param1:MouseEvent) : void
      {
         _mainPopup.answer3.voteBtn.mouse.gotoAndStop(0);
      }
      
      private function onSubmitBtnDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(_currentSelection >= 0 && _mainPopup.bodyTxt.visible && _nextQuestionTimer <= 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _shuffler.length)
            {
               if(_shuffler[_loc2_] == 2)
               {
                  break;
               }
               _loc2_++;
            }
            if(_loc2_ == 0)
            {
               _mainPopup.answer3.txtHighlight.visible = true;
               _mainPopup.answer3.txtHighlight.y = -85;
               _mainPopup.answer3.correct.y = -78;
            }
            else if(_loc2_ == 1)
            {
               _mainPopup.answer3.txtHighlight.visible = true;
               _mainPopup.answer3.txtHighlight.y = -55;
               _mainPopup.answer3.correct.y = -49;
            }
            else
            {
               _mainPopup.answer3.txtHighlight.visible = true;
               _mainPopup.answer3.txtHighlight.y = -25;
               _mainPopup.answer3.correct.y = -20;
            }
            if(_currentSelection == _loc2_)
            {
               _questionsCorrect++;
               _mainPopup.answer3.correct.visible = true;
            }
            else
            {
               if(_currentSelection == 0)
               {
                  _mainPopup.answer3.wrong.y = -78;
               }
               else if(_currentSelection == 1)
               {
                  _mainPopup.answer3.wrong.y = -49;
               }
               else
               {
                  _mainPopup.answer3.wrong.y = -20;
               }
               _mainPopup.answer3.wrong.visible = true;
            }
            _mainPopup.answer3.voteBtn.mouse.visible = false;
            _mainPopup.answer3.voteBtn.down.visible = false;
            _nextQuestionTimer = 3;
            _soundMan.playByName(_soundNameHudExitSelect);
         }
      }
      
      private function checkClick(param1:MouseEvent) : void
      {
         if(_mainPopup.bodyTxt.visible && _nextQuestionTimer <= 0)
         {
            if(_mainPopup.mouseY > 224 && _mainPopup.mouseY < 251)
            {
               _currentSelection = 0;
               _mainPopup.answer3.voteBtn.mouse.visible = true;
               _mainPopup.answer3.voteBtn.mouse.gotoAndStop(0);
               _mainPopup.option1._circle.visible = true;
               _mainPopup.option2._circle.visible = false;
               _mainPopup.option3._circle.visible = false;
               _soundMan.playByName(_soundNameHudExitSelect);
            }
            else if(_mainPopup.mouseY > 253 && _mainPopup.mouseY < 280)
            {
               _currentSelection = 1;
               _mainPopup.answer3.voteBtn.mouse.visible = true;
               _mainPopup.answer3.voteBtn.mouse.gotoAndStop(0);
               _mainPopup.option1._circle.visible = false;
               _mainPopup.option2._circle.visible = true;
               _mainPopup.option3._circle.visible = false;
               _soundMan.playByName(_soundNameHudExitSelect);
            }
            else if(_mainPopup.mouseY > 282 && _mainPopup.mouseY < 309)
            {
               _currentSelection = 2;
               _mainPopup.answer3.voteBtn.mouse.visible = true;
               _mainPopup.answer3.voteBtn.mouse.gotoAndStop(0);
               _mainPopup.option1._circle.visible = false;
               _mainPopup.option2._circle.visible = false;
               _mainPopup.option3._circle.visible = true;
               _soundMan.playByName(_soundNameHudExitSelect);
            }
         }
      }
      
      private function nextQuestion() : void
      {
         if(_questionIndex >= _qAndAs.length)
         {
            showResults();
         }
         else
         {
            _mainPopup.questionNumberTxt.text = _questionIndex + 1 + "/10";
            _mainPopup.option1._circle.visible = false;
            _mainPopup.option2._circle.visible = false;
            _mainPopup.option3._circle.visible = false;
            _mainPopup.answer3.correct.visible = false;
            _mainPopup.answer3.wrong.visible = false;
            _currentSelection = -1;
            _mainPopup.answer3.txtHighlight.visible = false;
            LocalizationManager.translateId(_mainPopup.bodyTxt,_qAndAs[_questionIndex].q);
            if(_qAndAs[_questionIndex].a[2] == 11852)
            {
               if(Math.random() < 0.5)
               {
                  LocalizationManager.translateId(_mainPopup.answer3.answer1Txt,_qAndAs[_questionIndex].a[0]);
                  LocalizationManager.translateId(_mainPopup.answer3.answer2Txt,_qAndAs[_questionIndex].a[1]);
               }
               else
               {
                  LocalizationManager.translateId(_mainPopup.answer3.answer1Txt,_qAndAs[_questionIndex].a[1]);
                  LocalizationManager.translateId(_mainPopup.answer3.answer2Txt,_qAndAs[_questionIndex].a[0]);
               }
               LocalizationManager.translateId(_mainPopup.answer3.answer3Txt,_qAndAs[_questionIndex].a[2]);
               _shuffler[0] = 0;
               _shuffler[1] = 1;
               _shuffler[2] = 2;
            }
            else
            {
               randomizeArray(_shuffler);
               LocalizationManager.translateId(_mainPopup.answer3.answer1Txt,_qAndAs[_questionIndex].a[_shuffler[0]]);
               LocalizationManager.translateId(_mainPopup.answer3.answer2Txt,_qAndAs[_questionIndex].a[_shuffler[1]]);
               LocalizationManager.translateId(_mainPopup.answer3.answer3Txt,_qAndAs[_questionIndex].a[_shuffler[2]]);
            }
            _questionIndex++;
         }
      }
      
      private function showResults() : void
      {
         _mainPopup.answer3.txtHighlight.visible = false;
         _mainPopup.answer3.correct.visible = _mainPopup.answer3.wrong.visible = false;
         _mainPopup.option1.visible = _mainPopup.option2.visible = _mainPopup.option3.visible = _mainPopup.answer3.answer1Txt.visible = _mainPopup.answer3.answer2Txt.visible = _mainPopup.answer3.answer3Txt.visible = false;
         _mainPopup.bodyTxt.visible = false;
         _mainPopup.resultsTxt.visible = true;
         LocalizationManager.translateIdAndInsert(_mainPopup.resultsTxt,11865,_questionsCorrect,_qAndAs.length);
         if(_questionsCorrect == _qAndAs.length && gMainFrame.userInfo.userVarCache.getUserVarValueById(364) != 1)
         {
            awardGift();
         }
         addGemsToBalance(25);
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "mm")
         {
            if(param1[2] == "hs")
            {
               _serialNumber = parseInt(param1[3]);
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(_pauseGame == false)
            {
               if(_nextQuestionTimer > 0)
               {
                  _nextQuestionTimer -= _frameTime;
                  if(_nextQuestionTimer <= 0)
                  {
                     nextQuestion();
                  }
               }
            }
         }
      }
      
      private function onExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
      }
      
      private function onRetry() : void
      {
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      public function onCloseButton() : void
      {
         end(null);
      }
   }
}

