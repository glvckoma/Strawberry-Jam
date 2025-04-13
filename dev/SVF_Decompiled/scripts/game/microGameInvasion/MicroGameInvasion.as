package game.microGameInvasion
{
   import currency.UserCurrency;
   import den.DenItem;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import giftPopup.GiftPopup;
   import item.EquippedAvatars;
   import item.Item;
   
   public class MicroGameInvasion extends GameBase implements IMinigame
   {
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _bInit:Boolean;
      
      public var _soundMan:SoundManager;
      
      public var _theGame:Object;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _layerBack:Sprite;
      
      public var _sceneLoaded:Boolean;
      
      private var _prizePopup:GiftPopup;
      
      private var _playSuccessNumber:int;
      
      private var _prizeDenItem:DenItem;
      
      private var _prizeAccessory:Item;
      
      private var _prizePopupActive:Boolean;
      
      private var _serialNumber:int;
      
      private var _needGemsTimer:Number;
      
      private var _audio:Array = ["pi_menuEnter.mp3","pi_menuExit.mp3","pi_popupFireColor.mp3","pi_ufoDamaged.mp3","pi_ufoDestroyed.mp3","pi_ufoEnter.mp3","pi_ufoExit.mp3","pi_ufoTractorBeam.mp3","pi_ufoWarp.mp3","pi_weaponCharge.mp3","pi_weaponFire.mp3"];
      
      private var _soundNameMenuEnter:String = _audio[0];
      
      private var _soundNameMenuExit:String = _audio[1];
      
      private var _soundNamePopupFireColor:String = _audio[2];
      
      private var _soundNameUfoDamaged:String = _audio[3];
      
      private var _soundNameUfoDestroyed:String = _audio[4];
      
      private var _soundNameUfoEnter:String = _audio[5];
      
      private var _soundNameUfoExit:String = _audio[6];
      
      private var _soundNameUfoTractorBeam:String = _audio[7];
      
      private var _soundNameUfoWarp:String = _audio[8];
      
      private var _soundNameWeaponCharge:String = _audio[9];
      
      private var _soundNameWeaponFire:String = _audio[10];
      
      public function MicroGameInvasion()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameMenuEnter],_soundNameMenuEnter,1.12);
         _soundMan.addSoundByName(_audioByName[_soundNameMenuExit],_soundNameMenuExit,1.15);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupFireColor],_soundNamePopupFireColor,1.18);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoDamaged],_soundNameUfoDamaged,1.4);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoDestroyed],_soundNameUfoDestroyed,1.31);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoEnter],_soundNameUfoEnter,1.08);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoExit],_soundNameUfoExit,1.21);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoTractorBeam],_soundNameUfoTractorBeam,1.27);
         _soundMan.addSoundByName(_audioByName[_soundNameUfoWarp],_soundNameUfoWarp,1.38);
         _soundMan.addSoundByName(_audioByName[_soundNameWeaponCharge],_soundNameWeaponCharge,1.04);
         _soundMan.addSoundByName(_audioByName[_soundNameWeaponFire],_soundNameWeaponFire,1.41);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
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
         resetGame();
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyHandleDown);
         _bInit = false;
         removeLayer(_layerBack);
         removeLayer(_guiLayer);
         _layerBack = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _needGemsTimer = 0;
         if(!_bInit)
         {
            _layerBack = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBack);
            addChild(_guiLayer);
            loadScene("MicroGameInvasion/room_main.xroom",_audio);
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
         _loc4_ = _scene.getLayer("xbutton");
         addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _theGame = _scene.getLayer("thegame");
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId - 55)
            {
               case 0:
                  _theGame.loader.content.machine.setType(1);
                  break;
               default:
                  _theGame.loader.content.machine.setType(0);
            }
         }
         else
         {
            _theGame.loader.content.machine.setType(0);
         }
         _layerBack.addChild(_theGame.loader);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",keyHandleDown);
         startGame();
         super.sceneLoaded(param1);
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         if(_theGame)
         {
            switch(param1.keyCode)
            {
               case 13:
               case 32:
                  if(_theGame && _theGame.loader.content)
                  {
                     _theGame.loader.content.machine.shoot();
                     _theGame.loader.content.machine.respondYes();
                  }
                  break;
               case 8:
               case 46:
               case 27:
                  if(_theGame && _theGame.loader.content)
                  {
                     _theGame.loader.content.machine.respondNo();
                     break;
                  }
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
               if(param1[2] == "cp")
               {
                  if(param1[3] != "1" && param1[3] != "0")
                  {
                     _theGame.loader.content.machine.noGems();
                     _needGemsTimer = 3;
                  }
                  else
                  {
                     _playSuccessNumber = Math.random() * 10000 + 1;
                     _serialNumber = parseInt(param1[4]);
                     if(param1[5] == "1")
                     {
                        _prizeAccessory = null;
                        _prizeDenItem = new DenItem();
                        _prizeDenItem.initShopItem(param1[6],param1[8]);
                     }
                     else
                     {
                        _prizeDenItem = null;
                        _prizeAccessory = new Item();
                        _prizeAccessory.init(param1[6],0,param1[8],EquippedAvatars.forced());
                     }
                     _theGame.loader.content.machine.hasGems(_playSuccessNumber);
                  }
               }
            }
         }
      }
      
      private function keptItem() : void
      {
         stage.addEventListener("keyDown",keyHandleDown);
         var _loc2_:Number = 11 * 5 + (gMainFrame.server.userId + 99) * 3 + (_serialNumber + 49) * 5;
         var _loc3_:Number = (_serialNumber + gMainFrame.server.userId + 11) * 3 + 11 * 3;
         MinigameManager.msg(["cd",_loc2_,_loc3_]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         stage.addEventListener("keyDown",keyHandleDown);
         MinigameManager.msg(["cd","2","0"]);
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         _theGame.loader.content.machine.newRound();
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(_theGame && _theGame.loader.content)
            {
               if(_theGame.loader.content.machine.menuEnter)
               {
                  _theGame.loader.content.machine.menuEnter = false;
                  _soundMan.playByName(_soundNameMenuEnter);
               }
               if(_theGame.loader.content.machine.menuExit)
               {
                  _theGame.loader.content.machine.menuExit = false;
                  _soundMan.playByName(_soundNameMenuExit);
               }
               if(_theGame.loader.content.machine.popupFireColor)
               {
                  _theGame.loader.content.machine.popupFireColor = false;
                  _soundMan.playByName(_soundNamePopupFireColor);
               }
               if(_theGame.loader.content.machine.ufoDamaged)
               {
                  _theGame.loader.content.machine.ufoDamaged = false;
                  _soundMan.playByName(_soundNameUfoDamaged);
               }
               if(_theGame.loader.content.machine.ufoDestroyed)
               {
                  _theGame.loader.content.machine.ufoDestroyed = false;
                  _soundMan.playByName(_soundNameUfoDestroyed);
               }
               if(_theGame.loader.content.machine.rolloverSound)
               {
                  _theGame.loader.content.machine.rolloverSound = false;
                  AJAudio.playHudBtnRollover();
               }
               if(_theGame.loader.content.machine.clickSound)
               {
                  _theGame.loader.content.machine.clickSound = false;
                  AJAudio.playHudBtnClick();
               }
               if(_theGame.loader.content.machine.ufoEnter)
               {
                  _theGame.loader.content.machine.ufoEnter = false;
                  _soundMan.playByName(_soundNameUfoEnter);
               }
               if(_theGame.loader.content.machine.ufoExit)
               {
                  _theGame.loader.content.machine.ufoExit = false;
                  _soundMan.playByName(_soundNameUfoExit);
               }
               if(_theGame.loader.content.machine.ufoTractorBeam)
               {
                  _theGame.loader.content.machine.ufoTractorBeam = false;
                  _soundMan.playByName(_soundNameUfoTractorBeam);
               }
               if(_theGame.loader.content.machine.ufoWarp)
               {
                  _theGame.loader.content.machine.ufoWarp = false;
                  _soundMan.playByName(_soundNameUfoWarp);
               }
               if(_theGame.loader.content.machine.weaponCharge)
               {
                  _theGame.loader.content.machine.weaponCharge = false;
                  _soundMan.playByName(_soundNameWeaponCharge);
               }
               if(_theGame.loader.content.machine.weaponFire)
               {
                  _theGame.loader.content.machine.weaponFire = false;
                  _soundMan.playByName(_soundNameWeaponFire);
               }
               if(_needGemsTimer > 0)
               {
                  _needGemsTimer -= _frameTime;
                  if(_needGemsTimer <= 0)
                  {
                     end(null);
                     return;
                  }
               }
               else if(_prizePopup == null)
               {
                  if(_theGame.loader.content.machine.exit == true)
                  {
                     _theGame.loader.content.machine.exit = false;
                     onCloseButton();
                  }
                  else if(_theGame.loader.content.machine.end == true && !_prizePopupActive)
                  {
                     _theGame.loader.content.machine.end = false;
                     _loc3_ = int(_theGame.loader.content.machine.results);
                     _loc3_ = _loc3_ / 5 - (_playSuccessNumber + 39) * 7;
                     if(_loc3_ == 11)
                     {
                        _prizePopup = new GiftPopup();
                        _prizePopupActive = true;
                        stage.removeEventListener("keyDown",keyHandleDown);
                        if(_prizeDenItem != null)
                        {
                           _prizePopup.init(this.parent,_prizeDenItem.icon,_prizeDenItem.name,_prizeDenItem.defId,2,2,keptItem,rejectedItem,destroyPrizePopup);
                        }
                        else
                        {
                           _prizePopup.init(this.parent,_prizeAccessory.largeIcon,_prizeAccessory.name,_prizeAccessory.defId,2,1,keptItem,rejectedItem,destroyPrizePopup);
                        }
                     }
                     else
                     {
                        MinigameManager.msg(["cd","0","0"]);
                        _theGame.loader.content.machine.newRound();
                     }
                  }
                  else if(_theGame.loader.content.machine.clickedStart == true)
                  {
                     _theGame.loader.content.machine.clickedStart = false;
                     clickedStart();
                  }
               }
            }
         }
      }
      
      public function clickedStart() : void
      {
         var _loc1_:int = UserCurrency.getCurrency(0);
         MinigameManager.msg(["cp"]);
         _prizePopupActive = false;
         _theGame.loader.content.machine.end = false;
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      public function resetGame() : void
      {
      }
      
      public function onCloseButton() : void
      {
         end(null);
      }
   }
}

