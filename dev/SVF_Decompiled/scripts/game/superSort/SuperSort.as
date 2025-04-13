package game.superSort
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
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
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class SuperSort extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _displayAchievementTimer:Number;
      
      public var _theGame:Object;
      
      public var _soundMan:SoundManager;
      
      public var _rolloverTimer:Number;
      
      public var _loseTimer:Number;
      
      public var _greatJobtimer:Number;
      
      public var _iLevel:int;
      
      public var _iSuccessfulRecycleCount:int;
      
      private var _perfectSort:Boolean;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _greatJobPopup:MovieClip;
      
      private var _recycleImageMediaObject:MovieClip;
      
      private var _currentFact:int;
      
      private var _factsOrder:Array;
      
      private var _facts:Array = [{
         "imageID":501,
         "text":11872
      },{
         "imageID":502,
         "text":11873
      },{
         "imageID":503,
         "text":11874
      },{
         "imageID":504,
         "text":11875
      },{
         "imageID":505,
         "text":11876
      },{
         "imageID":506,
         "text":11877
      },{
         "imageID":507,
         "text":11878
      },{
         "imageID":508,
         "text":11879
      },{
         "imageID":509,
         "text":11880
      },{
         "imageID":510,
         "text":11881
      },{
         "imageID":511,
         "text":11882
      },{
         "imageID":512,
         "text":11883
      },{
         "imageID":513,
         "text":11884
      },{
         "imageID":514,
         "text":11885
      },{
         "imageID":515,
         "text":11886
      },{
         "imageID":516,
         "text":11887
      },{
         "imageID":517,
         "text":11888
      },{
         "imageID":518,
         "text":11889
      },{
         "imageID":519,
         "text":11890
      },{
         "imageID":520,
         "text":11891
      },{
         "imageID":521,
         "text":11892
      },{
         "imageID":522,
         "text":11893
      },{
         "imageID":523,
         "text":11894
      },{
         "imageID":524,
         "text":11895
      },{
         "imageID":525,
         "text":11896
      },{
         "imageID":526,
         "text":11897
      },{
         "imageID":527,
         "text":11898
      },{
         "imageID":528,
         "text":11899
      },{
         "imageID":529,
         "text":11900
      },{
         "imageID":530,
         "text":11901
      }];
      
      private const _audio:Array = ["ss_milk_carton.mp3","ss_paper_drop.mp3","ss_paper_stack.mp3","ss_plastic_chair.mp3","ss_plastic_garbage_can.mp3","ss_stick_imp.mp3","ss_stinger_great.mp3","ss_stinger_oops.mp3","ss_trampoline_item_bounce_large.mp3","ss_trampoline_item_bounce_small.mp3","ss_wood_gears_shift.mp3","ss_bottle_large.mp3","ss_bottle_small.mp3","ss_box_large.mp3","ss_box_small.mp3","ss_bucket_bottles.mp3","ss_gear_click.mp3","ss_item_fall_1.mp3","ss_item_fall_2.mp3","ss_item_fall_appears.mp3","ss_item_impact_1.mp3","ss_item_impact_2.mp3","ss_item_impact_3.mp3","ss_item_recycle_failed.mp3","ss_item_recycled_success.mp3","ss_hud_Select.mp3","ss_hud_rollover.mp3","ss_alarm.mp3","ss_electricity.mp3","ss_logo.mp3","ss_machine_break_final.mp3","ss_machine_break_start.mp3","ss_machine_breaking_lp.mp3"];
      
      private var _soundNameMilkCarton:String = _audio[0];
      
      private var _soundNamePaperDrop:String = _audio[1];
      
      private var _soundNamePaperStack:String = _audio[2];
      
      private var _soundNamePlasticChair:String = _audio[3];
      
      private var _soundNamePlasticGarbageCan:String = _audio[4];
      
      private var _soundNameStickImp:String = _audio[5];
      
      private var _soundNameStingerGreat:String = _audio[6];
      
      private var _soundNameStingerOops:String = _audio[7];
      
      private var _soundNameTrampolineItemBounceLarge:String = _audio[8];
      
      private var _soundNameTrampolineItemBounceSmall:String = _audio[9];
      
      private var _soundNameWoodGearsShift:String = _audio[10];
      
      private var _soundNameBottleLarge:String = _audio[11];
      
      private var _soundNameBottleSmall:String = _audio[12];
      
      private var _soundNameBoxLarge:String = _audio[13];
      
      private var _soundNameBoxSmall:String = _audio[14];
      
      private var _soundNameBucketBottles:String = _audio[15];
      
      private var _soundNameGearClick:String = _audio[16];
      
      private var _soundNameItemFall1:String = _audio[17];
      
      private var _soundNameItemFall2:String = _audio[18];
      
      private var _soundNameItemFallAppears:String = _audio[19];
      
      private var _soundNameItemImpact1:String = _audio[20];
      
      private var _soundNameItemImpact2:String = _audio[21];
      
      private var _soundNameItemImpact3:String = _audio[22];
      
      private var _soundNameItemRecycleFailed:String = _audio[23];
      
      private var _soundNameItemRecycledSuccess:String = _audio[24];
      
      private var _soundNameHudSelect:String = _audio[25];
      
      private var _soundNameHudRollover:String = _audio[26];
      
      private var _soundNameAlarm:String = _audio[27];
      
      private var _soundNameElectricity:String = _audio[28];
      
      private var _soundNameLogo:String = _audio[29];
      
      private var _soundNameMachineBreakFinal:String = _audio[30];
      
      private var _soundNameMachineBreakStart:String = _audio[31];
      
      private var _soundNameMachineBreakingLp:String = _audio[32];
      
      public var _SFX_SuperSort_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var _ss_machine_breaking_lpSound:SoundChannel;
      
      public function SuperSort()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_SuperSort_Music = _soundMan.addStream("aj_mus_sorting_game",0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameMilkCarton],_soundNameMilkCarton,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNamePaperDrop],_soundNamePaperDrop,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNamePaperStack],_soundNamePaperStack,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePlasticChair],_soundNamePlasticChair,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNamePlasticGarbageCan],_soundNamePlasticGarbageCan,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStickImp],_soundNameStickImp,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerGreat],_soundNameStingerGreat,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerOops],_soundNameStingerOops,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTrampolineItemBounceLarge],_soundNameTrampolineItemBounceLarge,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTrampolineItemBounceSmall],_soundNameTrampolineItemBounceSmall,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodGearsShift],_soundNameWoodGearsShift,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameBottleLarge],_soundNameBottleLarge,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameBottleSmall],_soundNameBottleSmall,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameBoxLarge],_soundNameBoxLarge,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameBoxSmall],_soundNameBoxSmall,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameBucketBottles],_soundNameBucketBottles,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameGearClick],_soundNameGearClick,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameItemFall1],_soundNameItemFall1,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameItemFall2],_soundNameItemFall2,0.12);
         _soundMan.addSoundByName(_audioByName[_soundNameItemFallAppears],_soundNameItemFallAppears,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameItemImpact1],_soundNameItemImpact1,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameItemImpact2],_soundNameItemImpact2,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameItemImpact3],_soundNameItemImpact3,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameItemRecycleFailed],_soundNameItemRecycleFailed,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameItemRecycledSuccess],_soundNameItemRecycledSuccess,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameHudSelect],_soundNameHudSelect,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameHudRollover],_soundNameHudRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameAlarm],_soundNameAlarm,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameElectricity],_soundNameElectricity,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameLogo],_soundNameLogo,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameMachineBreakFinal],_soundNameMachineBreakFinal,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameMachineBreakStart],_soundNameMachineBreakStart,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameMachineBreakingLp],_soundNameMachineBreakingLp,0.2);
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
            AchievementXtCommManager.requestSetUserVar(31,1);
         }
         if(_ss_machine_breaking_lpSound)
         {
            _ss_machine_breaking_lpSound.stop();
            _ss_machine_breaking_lpSound = null;
         }
         releaseBase();
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         resetGame();
         _bInit = false;
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         _displayAchievementTimer = 0;
         _ss_machine_breaking_lpSound = null;
         _loseTimer = 0;
         _rolloverTimer = 0;
         _greatJobtimer = 0;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("SuperSort/room_main.xroom",_audio);
            _mediaObjectHelper = null;
            _loadingImage = false;
            _greatJobPopup = null;
            _recycleImageMediaObject = null;
            _loc1_ = [];
            _loc2_ = 0;
            while(_loc2_ < _facts.length)
            {
               _loc1_.push(_loc2_);
               _loc2_++;
            }
            _currentFact = -1;
            _factsOrder = [];
            while(_loc1_.length > 0)
            {
               _factsOrder.push(_loc1_.splice(Math.round(Math.random() * (_loc1_.length - 1)),1)[0]);
            }
            loadNextRecycleImage();
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_SuperSort_Music,0,999999);
         _loc4_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         startGame();
         super.sceneLoaded(param1);
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         if(_theGame)
         {
            switch(int(param1.keyCode) - 37)
            {
               case 0:
                  _theGame.loader.content.paddleLeft();
                  break;
               case 2:
                  _theGame.loader.content.paddleRight();
            }
         }
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         if(_theGame)
         {
            switch(int(param1.keyCode) - 37)
            {
            }
         }
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
         var _loc3_:MovieClip = null;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(_rolloverTimer > 0)
            {
               _rolloverTimer -= _frameTime;
            }
            if(_theGame && _theGame.loader && _theGame.loader.content)
            {
               if(_theGame.loader.content.machine_breaking_lp)
               {
                  if(_ss_machine_breaking_lpSound == null)
                  {
                     _ss_machine_breaking_lpSound = _soundMan.playByName(_soundNameMachineBreakingLp,0,99999);
                  }
               }
               else if(_ss_machine_breaking_lpSound)
               {
                  _ss_machine_breaking_lpSound.stop();
                  _ss_machine_breaking_lpSound = null;
               }
               if(_theGame.loader.content.tutorial.tutorialOn && stage.focus != _theGame.loader)
               {
                  stage.stageFocusRect = false;
                  stage.focus = _theGame.loader;
               }
               if(_theGame.loader.content.alarm)
               {
                  _theGame.loader.content.alarm = false;
                  _soundMan.playByName(_soundNameAlarm);
               }
               if(_theGame.loader.content.electricity)
               {
                  _theGame.loader.content.electricity = false;
                  _soundMan.playByName(_soundNameElectricity);
               }
               if(_theGame.loader.content.logo)
               {
                  _theGame.loader.content.logo = false;
                  _soundMan.playByName(_soundNameLogo);
               }
               if(_theGame.loader.content.machine_break_final)
               {
                  _theGame.loader.content.machine_break_final = false;
                  _soundMan.playByName(_soundNameMachineBreakFinal);
               }
               if(_theGame.loader.content.machine_break_start)
               {
                  _theGame.loader.content.machine_break_start = false;
                  _soundMan.playByName(_soundNameMachineBreakStart);
               }
               if(_theGame.loader.content.hud_select)
               {
                  _theGame.loader.content.hud_select = false;
                  _soundMan.playByName(_soundNameHudSelect);
               }
               if(_theGame.loader.content.hud_rollover)
               {
                  _theGame.loader.content.hud_rollover = false;
                  if(_rolloverTimer <= 0)
                  {
                     _rolloverTimer = 0.2;
                     _soundMan.playByName(_soundNameHudRollover);
                  }
               }
               if(_theGame.loader.content.wood_gears_shift)
               {
                  _theGame.loader.content.wood_gears_shift = false;
                  _soundMan.playByName(_soundNameWoodGearsShift);
               }
               if(_theGame.loader.content.trampoline_item_bounce_small)
               {
                  _theGame.loader.content.trampoline_item_bounce_small = false;
                  _soundMan.playByName(_soundNameTrampolineItemBounceSmall);
               }
               if(_theGame.loader.content.trampoline_item_bounce_large)
               {
                  _theGame.loader.content.trampoline_item_bounce_large = false;
                  _soundMan.playByName(_soundNameTrampolineItemBounceLarge);
               }
               if(_theGame.loader.content.stinger_oops)
               {
                  _theGame.loader.content.stinger_oops = false;
                  _soundMan.playByName(_soundNameStingerOops);
               }
               if(_theGame.loader.content.stinger_great)
               {
                  _theGame.loader.content.stinger_great = false;
                  _soundMan.playByName(_soundNameStingerGreat);
               }
               if(_theGame.loader.content.stick_imp)
               {
                  _theGame.loader.content.stick_imp = false;
                  _soundMan.playByName(_soundNameStickImp);
               }
               if(_theGame.loader.content.plastic_garbage_can)
               {
                  _theGame.loader.content.plastic_garbage_can = false;
                  _soundMan.playByName(_soundNamePlasticGarbageCan);
               }
               if(_theGame.loader.content.plastic_chair)
               {
                  _theGame.loader.content.plastic_chair = false;
                  _soundMan.playByName(_soundNamePlasticChair);
               }
               if(_theGame.loader.content.paper_stack)
               {
                  _theGame.loader.content.paper_stack = false;
                  _soundMan.playByName(_soundNamePaperStack);
               }
               if(_theGame.loader.content.paper_drop)
               {
                  _theGame.loader.content.paper_drop = false;
                  _soundMan.playByName(_soundNamePaperDrop);
               }
               if(_theGame.loader.content.milk_carton)
               {
                  _theGame.loader.content.milk_carton = false;
                  _soundMan.playByName(_soundNameMilkCarton);
               }
               if(_theGame.loader.content.item_recycled_success)
               {
                  _iSuccessfulRecycleCount++;
                  if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(37,_iSuccessfulRecycleCount);
                     _displayAchievementTimer = 1;
                  }
                  _theGame.loader.content.item_recycled_success = false;
                  _soundMan.playByName(_soundNameItemRecycledSuccess);
               }
               if(_theGame.loader.content.item_recycle_failed)
               {
                  _perfectSort = false;
                  _iSuccessfulRecycleCount = 0;
                  _theGame.loader.content.item_recycle_failed = false;
                  _soundMan.playByName(_soundNameItemRecycleFailed);
               }
               if(_theGame.loader.content.item_impact_3)
               {
                  _theGame.loader.content.item_impact_3 = false;
                  _soundMan.playByName(_soundNameItemImpact3);
               }
               if(_theGame.loader.content.item_impact_2)
               {
                  _theGame.loader.content.item_impact_2 = false;
                  _soundMan.playByName(_soundNameItemImpact2);
               }
               if(_theGame.loader.content.item_impact_1)
               {
                  _theGame.loader.content.item_impact_1 = false;
                  _soundMan.playByName(_soundNameItemImpact1);
               }
               if(_theGame.loader.content.item_fall_appears)
               {
                  _theGame.loader.content.item_fall_appears = false;
                  _soundMan.playByName(_soundNameItemFallAppears);
               }
               if(_theGame.loader.content.item_fall_2)
               {
                  _theGame.loader.content.item_fall_2 = false;
                  _soundMan.playByName(_soundNameItemFall2);
               }
               if(_theGame.loader.content.item_fall_1)
               {
                  _theGame.loader.content.item_fall_1 = false;
                  _soundMan.playByName(_soundNameItemFall1);
               }
               if(_theGame.loader.content.gear_click)
               {
                  _theGame.loader.content.gear_click = false;
                  _soundMan.playByName(_soundNameGearClick);
               }
               if(_theGame.loader.content.bucket_bottles)
               {
                  _theGame.loader.content.bucket_bottles = false;
                  _soundMan.playByName(_soundNameBucketBottles);
               }
               if(_theGame.loader.content.box_small)
               {
                  _theGame.loader.content.box_small = false;
                  _soundMan.playByName(_soundNameBoxSmall);
               }
               if(_theGame.loader.content.box_large)
               {
                  _theGame.loader.content.box_large = false;
                  _soundMan.playByName(_soundNameBoxLarge);
               }
               if(_theGame.loader.content.bottle_small)
               {
                  _theGame.loader.content.bottle_small = false;
                  _soundMan.playByName(_soundNameBottleSmall);
               }
               if(_theGame.loader.content.bottle_large)
               {
                  _theGame.loader.content.bottle_large = false;
                  _soundMan.playByName(_soundNameBottleLarge);
               }
            }
            if(_loseTimer > 0)
            {
               _loseTimer -= _frameTime;
               if(_loseTimer <= 0)
               {
                  stage.addEventListener("keyDown",replayKeyDown);
                  _loc3_ = showDlg("superSort_Game_Over",[{
                     "name":"button_yes",
                     "f":onLose_Yes
                  },{
                     "name":"button_no",
                     "f":onLose_No
                  }]);
                  _loc3_.x = 450;
                  _loc3_.y = 275;
                  LocalizationManager.translateIdAndInsert(_loc3_.text_score,_theGame.loader.content.totalGems == 1 ? 11114 : 11097,_theGame.loader.content.totalGems);
                  _loc3_.text_score.text.toLowerCase();
                  addGemsToBalance(_theGame.loader.content.gems);
               }
            }
            else if(_greatJobtimer > 0)
            {
               _greatJobtimer -= _frameTime;
               if(_greatJobtimer <= 0)
               {
                  _loc3_ = showDlg("superSort_Great_Job",[{
                     "name":"button_nextlevel",
                     "f":onNextLevel
                  }]);
                  _loc3_.x = 450;
                  _loc3_.y = 275;
                  _loc3_.text_hitCont.text_hit.text = _theGame.loader.content.score;
                  _loc3_.Gems_EarnedCont.Gems_Earned.text = _theGame.loader.content.gems;
                  stage.stageFocusRect = false;
                  stage.focus = _loc3_;
                  _loc3_.addEventListener("keyDown",keyboardPressedDlg);
                  _loc3_.perfect.visible = _perfectSort;
                  _greatJobPopup = _loc3_;
                  if(_recycleImageMediaObject)
                  {
                     _greatJobPopup.result_pic.addChild(_recycleImageMediaObject);
                  }
                  LocalizationManager.translateId(_loc3_.result_factCont.result_fact,_facts[_factsOrder[_currentFact]].text);
                  addGemsToBalance(_theGame.loader.content.gems);
                  if(_perfectSort)
                  {
                     addGemsToBalance(15);
                  }
               }
            }
            else if(_pauseGame == false)
            {
               if(_displayAchievementTimer > 0)
               {
                  _displayAchievementTimer -= _frameTime;
                  if(_displayAchievementTimer <= 0)
                  {
                     _displayAchievementTimer = 0;
                     AchievementManager.displayNewAchievements();
                  }
               }
               if(_theGame && _theGame.loader && _theGame.loader.content)
               {
                  if(_theGame.loader.content.lose)
                  {
                     _loseTimer = 0.5;
                  }
                  else if(_theGame.loader.content.levelDone)
                  {
                     _greatJobtimer = 0.5;
                  }
               }
            }
         }
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onLose_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onLose_No();
         }
      }
      
      public function loadNextRecycleImage() : void
      {
         if(!_loadingImage)
         {
            _currentFact++;
            if(_currentFact >= _factsOrder.length)
            {
               _currentFact = 0;
            }
            _loadingImage = true;
            if(_mediaObjectHelper != null)
            {
               _mediaObjectHelper.destroy();
            }
            _mediaObjectHelper = new MediaHelper();
            _mediaObjectHelper.init(_facts[_factsOrder[_currentFact]].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         if(_recycleImageMediaObject != null)
         {
            _recycleImageMediaObject.parent.removeChild(_recycleImageMediaObject);
         }
         param1.x = 0;
         param1.y = 0;
         _recycleImageMediaObject = param1;
         if(_greatJobPopup)
         {
            _greatJobPopup.result_pic.addChild(_recycleImageMediaObject);
         }
         _loadingImage = false;
      }
      
      public function startGame() : void
      {
         resetGame();
         _perfectSort = true;
         if(_soundMan != null && _musicLoop == null)
         {
            _musicLoop = _soundMan.playStream(_SFX_SuperSort_Music,0,999999);
         }
         _iLevel = 0;
         _iSuccessfulRecycleCount = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(!_theGame)
         {
         }
      }
      
      public function resetGame() : void
      {
      }
      
      public function onCloseButton() : void
      {
         if(_theGame)
         {
            _theGame.loader.content.pauseGame();
         }
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
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onLose_No() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onLose_Yes() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         _perfectSort = true;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(31,1);
            _displayAchievementTimer = 1;
         }
         hideDlg();
         _loseTimer = 0;
         _greatJobtimer = 0;
         _theGame.loader.content.newGame();
      }
      
      private function onNextLevel() : void
      {
         if(_recycleImageMediaObject)
         {
            _recycleImageMediaObject.parent.removeChild(_recycleImageMediaObject);
            _recycleImageMediaObject = null;
         }
         if(!_loadingImage)
         {
            loadNextRecycleImage();
         }
         _greatJobPopup = null;
         _perfectSort = true;
         hideDlg();
         stage.focus = _theGame.loader;
         _loseTimer = 0;
         _greatJobtimer = 0;
         _theGame.loader.content.nextLevel();
         _iLevel++;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(32,_iLevel);
            _displayAchievementTimer = 1;
         }
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onExit_No() : void
      {
         if(_theGame)
         {
            _theGame.loader.content.unpauseGame();
         }
         hideDlg();
      }
      
      private function keyboardPressedDlg(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 32:
            case 13:
               onNextLevel();
               stage.focus = this;
         }
      }
   }
}

