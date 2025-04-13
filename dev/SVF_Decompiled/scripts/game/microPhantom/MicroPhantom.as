package game.microPhantom
{
   import com.sbi.corelib.audio.SBAudio;
   import den.DenItem;
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
   import giftPopup.GiftPopup;
   import localization.LocalizationManager;
   
   public class MicroPhantom extends GameBase implements IMinigame
   {
      private static const GEMS_PER_PHANTOM:int = 3;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static var SFX_PHANTOM_TORCHACTIVE:Class;
      
      public static var SFX_PHANTOM_TORCHFLAME:Class;
      
      public static var SFX_PHANTOM_IDLE:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _loseTimer:Number;
      
      public var _winnerReset:Boolean;
      
      public var _totalPhantomsKilled:int;
      
      public var _torchCollisionTimer:Number;
      
      public var _torchCollisionVolume:Number;
      
      public var _torchRelativeVolume:Number;
      
      public var _phantomIdleVolume:Number;
      
      public var _phantomRelativeVolume:Number;
      
      public var _torchFlameVolume:Number;
      
      public var _torchFlameRelativeVolume:Number;
      
      public var _soundMan:SoundManager;
      
      public var _hasItem:Boolean;
      
      private var _prizePopup:GiftPopup;
      
      private var _prize:DenItem;
      
      private var _roundCounter:int;
      
      private var _audio:Array = ["phantom_eats_candy1.mp3","phantom_eats_candy2.mp3","phantom_eats_candy3.mp3","phantom_eats_candy4.mp3","phantom_growl1.mp3","phantom_growl2.mp3","phantom_growl3.mp3","phantom_growl4.mp3","phantom_growl5.mp3","phantom_light_shaft_off.mp3","phantom_light_shaft_on.mp3","phantom_prize.mp3","phantom_stinger_fail.mp3","phantom_stinger_success.mp3","phantom_torch_collision.mp3","phantom_torch_collision2.mp3","phantom_torch_collision3.mp3","vo_phatom_death1.mp3","vo_phatom_death2.mp3","vo_phatom_death3.mp3","vo_phatom_death4.mp3","vo_phatom_death5.mp3","vo_phatom_death6.mp3","MG_pop_ups.mp3","phantom_candy_fall.mp3"];
      
      private var _soundNameEatsCandy1:String = _audio[0];
      
      private var _soundNameEatsCandy2:String = _audio[1];
      
      private var _soundNameEatsCandy3:String = _audio[2];
      
      private var _soundNameEatsCandy4:String = _audio[3];
      
      private var _soundNameGrowl1:String = _audio[4];
      
      private var _soundNameGrowl2:String = _audio[5];
      
      private var _soundNameGrowl3:String = _audio[6];
      
      private var _soundNameGrowl4:String = _audio[7];
      
      private var _soundNameGrowl5:String = _audio[8];
      
      private var _soundNameLightShaftOff:String = _audio[9];
      
      private var _soundNameLightShaftOn:String = _audio[10];
      
      private var _soundNamePrize:String = _audio[11];
      
      private var _soundNameStingerFail:String = _audio[12];
      
      private var _soundNameStingerSuccess:String = _audio[13];
      
      private var _soundNameCollision1:String = _audio[14];
      
      private var _soundNameCollision2:String = _audio[15];
      
      private var _soundNameCollision3:String = _audio[16];
      
      private var _soundNameDeath1:String = _audio[17];
      
      private var _soundNameDeath2:String = _audio[18];
      
      private var _soundNameDeath3:String = _audio[19];
      
      private var _soundNameDeath4:String = _audio[20];
      
      private var _soundNameDeath5:String = _audio[21];
      
      private var _soundNameDeath6:String = _audio[22];
      
      private var _soundNamePopUps:String = _audio[23];
      
      private var _soundNameCandyFall:String = _audio[24];
      
      private var _SFX_Phantom_TorchActive_Instance:SoundChannel;
      
      private var _SFX_Phantom_TorchFlame_Instance:SoundChannel;
      
      private var _SFX_Phantom_Idle_Instance:SoundChannel;
      
      public function MicroPhantom()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameEatsCandy1],_soundNameEatsCandy1,0.47);
         _soundMan.addSoundByName(_audioByName[_soundNameEatsCandy2],_soundNameEatsCandy2,0.47);
         _soundMan.addSoundByName(_audioByName[_soundNameEatsCandy3],_soundNameEatsCandy3,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameEatsCandy4],_soundNameEatsCandy4,0.36);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowl1],_soundNameGrowl1,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowl2],_soundNameGrowl2,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowl3],_soundNameGrowl3,0.54);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowl4],_soundNameGrowl4,0.49);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowl5],_soundNameGrowl5,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameLightShaftOff],_soundNameLightShaftOff,1.01);
         _soundMan.addSoundByName(_audioByName[_soundNameLightShaftOn],_soundNameLightShaftOn,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNamePrize],_soundNamePrize,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerSuccess],_soundNameStingerSuccess,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameCollision1],_soundNameCollision1,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCollision2],_soundNameCollision2,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCollision3],_soundNameCollision3,1);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath1],_soundNameDeath1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath2],_soundNameDeath2,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath3],_soundNameDeath3,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath4],_soundNameDeath4,0.52);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath5],_soundNameDeath5,0.48);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath6],_soundNameDeath6,0.46);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUps],_soundNamePopUps,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameCandyFall],_soundNameCandyFall,1);
         _torchRelativeVolume = 0.15;
         _torchFlameRelativeVolume = 0.29;
         _phantomRelativeVolume = 0.24;
         _soundMan.addSound(SFX_PHANTOM_TORCHACTIVE,_torchRelativeVolume,"SFX_PHANTOM_TORCHACTIVE");
         _soundMan.addSound(SFX_PHANTOM_TORCHFLAME,_torchFlameRelativeVolume,"SFX_PHANTOM_TORCHFLAME");
         _soundMan.addSound(SFX_PHANTOM_IDLE,_phantomRelativeVolume,"SFX_PHANTOM_IDLE");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         MinigameManager.msg(["pi"]);
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         hideDlg();
         releaseBase();
         stage.removeEventListener("keyDown",onLoseKeyDown);
         stage.removeEventListener("keyDown",onWinKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         resetGame();
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _SFX_Phantom_TorchActive_Instance = null;
         _SFX_Phantom_Idle_Instance = null;
         _SFX_Phantom_TorchFlame_Instance = null;
         _hasItem = false;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroPhantom/room_main.xroom",_audio);
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
         SFX_PHANTOM_TORCHACTIVE = getDefinitionByName("phantom_torch_active") as Class;
         if(SFX_PHANTOM_TORCHACTIVE == null)
         {
            throw new Error("Sound not found! name:phantom_torch_active");
         }
         SFX_PHANTOM_TORCHFLAME = getDefinitionByName("Phantom_torch_flame") as Class;
         if(SFX_PHANTOM_TORCHFLAME == null)
         {
            throw new Error("Sound not found! name:Phantom_torch_flame");
         }
         SFX_PHANTOM_IDLE = getDefinitionByName("phantom_idle") as Class;
         if(SFX_PHANTOM_IDLE == null)
         {
            throw new Error("Sound not found! name:phantom_idle");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
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
               if(param1[2] == "cp")
               {
                  if(param1[3] == "0")
                  {
                     _hasItem = true;
                  }
                  else
                  {
                     _hasItem = false;
                     _prize = new DenItem();
                     _prize.initShopItem(param1[4],param1[6]);
                  }
               }
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc3_:SoundTransform = null;
         var _loc4_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc2_:Array = null;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(!SBAudio.isMusicMuted)
            {
               if(_theGame.loader.content.sNumPhantoms > 0)
               {
                  if(_torchFlameVolume < 1)
                  {
                     _torchFlameVolume += _frameTime;
                     if(_torchFlameVolume > 1)
                     {
                        _torchFlameVolume = 1;
                     }
                     if(_SFX_Phantom_TorchFlame_Instance == null)
                     {
                        _SFX_Phantom_TorchFlame_Instance = _soundMan.play(SFX_PHANTOM_TORCHFLAME,0,99999);
                     }
                     _loc3_ = new SoundTransform(_torchFlameVolume * _torchFlameRelativeVolume,0);
                     _SFX_Phantom_TorchFlame_Instance.soundTransform = _loc3_;
                  }
                  if(_phantomIdleVolume < 1)
                  {
                     _phantomIdleVolume += _frameTime;
                     if(_phantomIdleVolume > 1)
                     {
                        _phantomIdleVolume = 1;
                     }
                     if(_SFX_Phantom_Idle_Instance == null)
                     {
                        _SFX_Phantom_Idle_Instance = _soundMan.play(SFX_PHANTOM_IDLE,0,99999);
                     }
                     _loc3_ = new SoundTransform(_phantomIdleVolume * _phantomRelativeVolume,0);
                     _SFX_Phantom_Idle_Instance.soundTransform = _loc3_;
                  }
               }
               else
               {
                  if(_torchFlameVolume > 0)
                  {
                     _torchFlameVolume -= _frameTime / 0.35;
                     if(_torchFlameVolume <= 0 || _SFX_Phantom_TorchFlame_Instance == null)
                     {
                        _torchFlameVolume = 0;
                        if(_SFX_Phantom_TorchFlame_Instance)
                        {
                           _soundMan.stop(_SFX_Phantom_TorchFlame_Instance);
                           _SFX_Phantom_TorchFlame_Instance = null;
                        }
                     }
                     else
                     {
                        _loc3_ = new SoundTransform(_torchFlameVolume * _torchFlameRelativeVolume,0);
                        _SFX_Phantom_TorchFlame_Instance.soundTransform = _loc3_;
                     }
                  }
                  if(_phantomIdleVolume > 0)
                  {
                     _phantomIdleVolume -= _frameTime / 0.35;
                     if(_phantomIdleVolume <= 0 || _SFX_Phantom_Idle_Instance == null)
                     {
                        _phantomIdleVolume = 0;
                        if(_SFX_Phantom_Idle_Instance)
                        {
                           _soundMan.stop(_SFX_Phantom_Idle_Instance);
                           _SFX_Phantom_Idle_Instance = null;
                        }
                     }
                     else
                     {
                        _loc3_ = new SoundTransform(_phantomIdleVolume * _phantomRelativeVolume,0);
                        _SFX_Phantom_Idle_Instance.soundTransform = _loc3_;
                     }
                  }
               }
               if(_torchCollisionTimer > 0)
               {
                  _torchCollisionTimer -= _frameTime;
                  if(_torchCollisionTimer > 0)
                  {
                     if(_torchCollisionVolume < 1)
                     {
                        _torchCollisionVolume += _frameTime;
                        if(_torchCollisionVolume > 1)
                        {
                           _torchCollisionVolume = 1;
                        }
                        _loc3_ = new SoundTransform(_torchCollisionVolume * _torchRelativeVolume,0);
                        _SFX_Phantom_TorchActive_Instance.soundTransform = _loc3_;
                     }
                  }
               }
               else if(_SFX_Phantom_TorchActive_Instance)
               {
                  _torchCollisionVolume -= _frameTime / 0.15;
                  if(_torchCollisionVolume <= 0)
                  {
                     _soundMan.stop(_SFX_Phantom_TorchActive_Instance);
                     _SFX_Phantom_TorchActive_Instance = null;
                  }
                  else
                  {
                     _loc3_ = new SoundTransform(_torchCollisionVolume * _torchRelativeVolume,0);
                     _SFX_Phantom_TorchActive_Instance.soundTransform = _loc3_;
                  }
               }
               if(_theGame.loader.content.sCandyDrop)
               {
                  _soundMan.playByName(_soundNameCandyFall);
                  _theGame.loader.content.sCandyDrop = false;
               }
               if(_theGame.loader.content.sTorchCollision)
               {
                  if(_torchCollisionTimer <= 0)
                  {
                     _loc4_ = new Array(_soundNameCollision1,_soundNameCollision2,_soundNameCollision3);
                     _loc8_ = Math.random() * _loc4_.length;
                     _soundMan.playByName(_loc4_[_loc8_]);
                     if(_SFX_Phantom_TorchActive_Instance == null)
                     {
                        _torchCollisionVolume = 0;
                        _SFX_Phantom_TorchActive_Instance = _soundMan.play(SFX_PHANTOM_TORCHACTIVE,0,99999);
                        _loc3_ = new SoundTransform(0,0);
                        _SFX_Phantom_TorchActive_Instance.soundTransform = _loc3_;
                     }
                  }
                  _torchCollisionTimer = 0.25;
               }
            }
            if(_theGame.loader.content.sNewPhantom)
            {
               _loc6_ = new Array(_soundNameGrowl1,_soundNameGrowl2,_soundNameGrowl3,_soundNameGrowl4,_soundNameGrowl5);
               _loc8_ = Math.random() * (_loc6_.length * 1.5);
               if(_loc8_ < _loc6_.length)
               {
                  _soundMan.playByName(_loc6_[_loc8_]);
               }
               _theGame.loader.content.sNewPhantom = false;
            }
            if(_theGame.loader.content.sPhantomDied)
            {
               _loc7_ = new Array(_soundNameDeath1,_soundNameDeath2,_soundNameDeath3,_soundNameDeath4,_soundNameDeath5,_soundNameDeath6);
               _soundMan.playByName(_soundNameLightShaftOff);
               _loc8_ = Math.random() * _loc7_.length;
               _soundMan.playByName(_loc7_[_loc8_]);
               _theGame.loader.content.sPhantomDied = false;
            }
            if(_theGame.loader.content.sLightShaftAppeared)
            {
               _soundMan.playByName(_soundNameLightShaftOn);
               _theGame.loader.content.sLightShaftAppeared = false;
            }
            if(_theGame.loader.content.sPopups)
            {
               _soundMan.playByName(_soundNamePopUps);
               _theGame.loader.content.sPopups = false;
            }
            if(_pauseGame == false)
            {
               if(_winnerReset)
               {
                  if(_theGame && _theGame.loader.content.winner)
                  {
                     _roundCounter++;
                     if(_roundCounter == 5 && _hasItem == false && _prize != null)
                     {
                        _prizePopup = new GiftPopup();
                        _prizePopup.init(this.parent,_prize.icon,_prize.name,_prize.defId,2,2,keptItem,rejectedItem,destroyPrizePopup);
                        _soundMan.playByName(_soundNamePrize);
                     }
                     else
                     {
                        onWin();
                     }
                     _winnerReset = false;
                  }
                  else if(_loseTimer == 0)
                  {
                     if(_theGame && _theGame.loader.content.lose)
                     {
                        if(_closeBtn)
                        {
                           _closeBtn.visible = false;
                        }
                        _loseTimer = 1.25;
                        _soundMan.playByName(_soundNameStingerFail);
                        _loc2_ = new Array(_soundNameEatsCandy1,_soundNameEatsCandy2,_soundNameEatsCandy3,_soundNameEatsCandy4);
                        _loc8_ = Math.random() * _loc2_.length;
                        _soundMan.playByName(_loc2_[_loc8_]);
                     }
                  }
                  else
                  {
                     _loseTimer -= _frameTime;
                     if(_loseTimer <= 0)
                     {
                        onLose();
                     }
                  }
               }
               else if(_theGame && _theGame.loader.content.winner == false)
               {
                  _winnerReset = true;
               }
            }
         }
      }
      
      public function startGame() : void
      {
         resetGame();
         _roundCounter = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _torchCollisionTimer = 0;
         _torchCollisionVolume = 0;
         _phantomIdleVolume = 0;
         _torchFlameVolume = 0;
         _torchFlameRelativeVolume = 0.6;
         _totalPhantomsKilled = 0;
         _loseTimer = 0;
         _winnerReset = true;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _theGame.loader.content.sLightFrameOffset = 12;
         }
      }
      
      public function resetGame() : void
      {
         if(_SFX_Phantom_TorchActive_Instance)
         {
            _torchCollisionVolume = 0;
            _soundMan.stop(_SFX_Phantom_TorchActive_Instance);
            _SFX_Phantom_TorchActive_Instance = null;
         }
         if(_SFX_Phantom_Idle_Instance)
         {
            _phantomIdleVolume = 0;
            _soundMan.stop(_SFX_Phantom_Idle_Instance);
            _SFX_Phantom_Idle_Instance = null;
         }
         if(_SFX_Phantom_TorchFlame_Instance)
         {
            _torchFlameVolume = 0;
            _soundMan.stop(_SFX_Phantom_TorchFlame_Instance);
            _SFX_Phantom_TorchFlame_Instance = null;
         }
      }
      
      public function onCloseButton() : void
      {
         end(null);
      }
      
      private function onLoseKeyDown(param1:KeyboardEvent) : void
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
      
      public function onLose() : void
      {
         var _loc1_:MovieClip = showDlg("PhMicro_Game_Over",[{
            "name":"button_yes",
            "f":onLose_Yes
         },{
            "name":"button_no",
            "f":onLose_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",onLoseKeyDown);
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_totalPhantomsKilled * 3);
      }
      
      private function onLose_No() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onLose_Yes() : void
      {
         stage.removeEventListener("keyDown",onLoseKeyDown);
         hideDlg();
         _theGame.loader.content.reset();
         startGame();
      }
      
      private function onWinKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onWinnerNextLevel();
         }
      }
      
      public function onWin() : void
      {
         var _loc1_:MovieClip = showDlg("PhMicro_Great_Job",[{
            "name":"button_nextlevel",
            "f":onWinnerNextLevel
         }]);
         var _loc2_:int = (_theGame.loader.content.points - _totalPhantomsKilled) * 3;
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",onWinKeyDown);
         LocalizationManager.translateIdAndInsert(_loc1_.Text_hit,11624,_theGame.loader.content.points);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11554,_loc2_);
         addGemsToBalance(_loc2_);
         _totalPhantomsKilled = _theGame.loader.content.points;
         LocalizationManager.translateIdAndInsert(_loc1_.Total_Gems,11549,_totalPhantomsKilled * 3);
         _soundMan.playByName(_soundNameStingerSuccess);
      }
      
      private function onWinnerNextLevel() : void
      {
         stage.removeEventListener("keyDown",onWinKeyDown);
         _theGame.loader.content.gotoAndPlay("nextRound");
         hideDlg();
      }
      
      private function keptItem() : void
      {
         _hasItem = true;
         MinigameManager.msg(["pd","1"]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         MinigameManager.msg(["pd","0"]);
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
            onWin();
         }
      }
   }
}

