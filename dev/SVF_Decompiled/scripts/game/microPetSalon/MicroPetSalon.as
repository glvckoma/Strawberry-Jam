package game.microPetSalon
{
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gui.DarkenManager;
   
   public class MicroPetSalon extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const COST_OF_PET:int = 200;
      
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
      
      protected var _doneButton:MovieClip;
      
      protected var _resetButton:MovieClip;
      
      public var _soundMan:SoundManager;
      
      public var _pet:Object;
      
      public var _pet2:Object;
      
      public var _updatingPet:Boolean;
      
      public var _petLoadedCount:int;
      
      private var _audio:Array = ["aj_PS_ChairSpin.mp3","aj_PS_ChairSpinReveal.mp3","aj_PS_cupboardClose.mp3","aj_PS_cupboardOpen.mp3","aj_PS_SalonDrawersClose.mp3","aj_PS_SalonDrawersOpen.mp3","aj_PS_trunkClose.mp3","aj_PS_trunkOpen.mp3","aj_PS_ItemSelect.mp3","aj_PS_petEnters.mp3","aj_PS_reset.mp3","aj_PS_RollOver.mp3"];
      
      private var _soundNameChairSpin:String = _audio[0];
      
      private var _soundNameChairSpinReveal:String = _audio[1];
      
      private var _soundNameCupboardClose:String = _audio[2];
      
      private var _soundNameCupboardOpen:String = _audio[3];
      
      private var _soundNameSalonDrawersClose:String = _audio[4];
      
      private var _soundNameSalonDrawersOpen:String = _audio[5];
      
      private var _soundNameTrunkClose:String = _audio[6];
      
      private var _soundNameTrunkOpen:String = _audio[7];
      
      private var _soundNameItemSelect:String = _audio[8];
      
      private var _soundNamePetEnters:String = _audio[9];
      
      private var _soundNameReset:String = _audio[10];
      
      private var _soundNameRollOver:String = _audio[11];
      
      public function MicroPetSalon()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameChairSpin],_soundNameChairSpin,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameChairSpinReveal],_soundNameChairSpinReveal,0.85);
         _soundMan.addSoundByName(_audioByName[_soundNameCupboardClose],_soundNameCupboardClose,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCupboardOpen],_soundNameCupboardOpen,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameSalonDrawersClose],_soundNameSalonDrawersClose,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSalonDrawersOpen],_soundNameSalonDrawersOpen,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameTrunkClose],_soundNameTrunkClose,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameTrunkOpen],_soundNameTrunkOpen,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameItemSelect],_soundNameItemSelect,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNamePetEnters],_soundNamePetEnters,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameReset],_soundNameReset,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameRollOver],_soundNameRollOver,0.5);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_layerMain)
         {
            releaseBase();
            stage.removeEventListener("keyDown",onCostCloseKeyDown);
            stage.removeEventListener("keyDown",onConfirmKeyDown);
            stage.removeEventListener("enterFrame",heartbeat);
            resetGame();
            _bInit = false;
            removeLayer(_layerMain);
            removeLayer(_guiLayer);
            _layerMain = null;
            _guiLayer = null;
            MinigameManager.leave();
         }
      }
      
      private function init() : void
      {
         _updatingPet = false;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroPetSalon/room_main.xroom",_audio);
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
         _resetButton = addBtn("PetSalon_reset",125,481,onResetDlg);
         _doneButton = addBtn("PetSalon_done",791,481,showDoneDlg);
         _closeBtn = addBtn("CloseButton",800,44,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _theGame.loader.content.showConfirm = false;
         _layerMain.addChild(_theGame.loader);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId - 81)
            {
               case 0:
                  _theGame.loader.content.specialItems();
            }
         }
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
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc4_:MovieClip = null;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(_pauseGame == false && _updatingPet == false)
            {
               if(_theGame && _theGame.loader && _theGame.loader.content)
               {
                  if(_theGame.loader.content.ChairSpin)
                  {
                     _theGame.loader.content.ChairSpin = false;
                     _soundMan.playByName(_soundNameChairSpin);
                  }
                  if(_theGame.loader.content.ChairSpinReveal)
                  {
                     _theGame.loader.content.ChairSpinReveal = false;
                     _soundMan.playByName(_soundNameChairSpinReveal);
                  }
                  if(_theGame.loader.content.cupboardClose)
                  {
                     _theGame.loader.content.cupboardClose = false;
                     _soundMan.playByName(_soundNameCupboardClose);
                  }
                  if(_theGame.loader.content.cupboardOpen)
                  {
                     _theGame.loader.content.cupboardOpen = false;
                     _soundMan.playByName(_soundNameCupboardOpen);
                  }
                  if(_theGame.loader.content.SalonDrawersClose)
                  {
                     _theGame.loader.content.SalonDrawersClose = false;
                     _soundMan.playByName(_soundNameSalonDrawersClose);
                  }
                  if(_theGame.loader.content.SalonDrawersOpen)
                  {
                     _theGame.loader.content.SalonDrawersOpen = false;
                     _soundMan.playByName(_soundNameSalonDrawersOpen);
                  }
                  if(_theGame.loader.content.trunkOpen)
                  {
                     _theGame.loader.content.trunkOpen = false;
                     _soundMan.playByName(_soundNameTrunkOpen);
                  }
                  if(_theGame.loader.content.trunkClose)
                  {
                     _theGame.loader.content.trunkClose = false;
                     _soundMan.playByName(_soundNameTrunkClose);
                  }
                  if(_theGame.loader.content.itemClicked)
                  {
                     _theGame.loader.content.itemClicked = false;
                     _soundMan.playByName(_soundNameItemSelect);
                  }
                  if(_theGame.loader.content.RollOver)
                  {
                     _theGame.loader.content.RollOver = false;
                     _soundMan.playByName(_soundNameRollOver);
                  }
                  if(_theGame.loader.content.showConfirm)
                  {
                     _theGame.loader.content.showConfirm = false;
                     _loc2_ = UserCurrency.getCurrency(0);
                     if(_loc2_ >= 200)
                     {
                        _loc4_ = showDlg("PetSalon_confirm",[{
                           "name":"yesBtn",
                           "f":onDone_Yes
                        },{
                           "name":"noBtn",
                           "f":onDone_No
                        }]);
                        _loc4_.x = 450;
                        _loc4_.y = 275 - 100;
                        stage.addEventListener("keyDown",onConfirmKeyDown);
                     }
                     else
                     {
                        _loc4_ = showDlg("PetSalon_costPopup",[{
                           "name":"x_btn",
                           "f":onCostClose
                        }]);
                        _loc4_.x = 450;
                        _loc4_.y = 275;
                        _loc4_.gemsTxt.text = _loc2_;
                        _loc4_.costTxt.text = 200;
                        _loc4_.needTxt.text = 200 - _loc2_;
                        stage.addEventListener("keyDown",onCostCloseKeyDown);
                     }
                  }
               }
            }
         }
      }
      
      private function onConfirmKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onDone_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onDone_No();
         }
      }
      
      private function onCostCloseKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onCostClose();
         }
      }
      
      public function startGame() : void
      {
         resetGame();
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _petLoadedCount = 0;
            _pet = MinigameManager.getActivePet(petLoaded);
            if(_pet == null)
            {
               _theGame.loader.content.setUpPet(null,0,0,0,0,0);
            }
            else
            {
               _pet2 = MinigameManager.getActivePet(petLoaded);
            }
         }
      }
      
      public function petLoaded(param1:MovieClip) : void
      {
         _petLoadedCount++;
         if(_petLoadedCount >= 2)
         {
            if(_pet.canGoInOcean() && MinigameManager.roomEnviroType == 1)
            {
               _theGame.loader.content.underWater();
            }
            _theGame.loader.content.setUpPet(_pet,_pet.getLBits(),_pet.getUBits(),_pet.getEBits(),_pet.getType(),MinigameManager.roomEnviroType,_pet2);
            _pet.getChildAt(0).pet.setAnim(1);
            _soundMan.playByName(_soundNamePetEnters);
         }
      }
      
      public function petUpdated(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         DarkenManager.showLoadingSpiral(false);
         if(!param1)
         {
            _loc2_ = showDlg("PetSalon_error",[{
               "name":"okBtn",
               "f":onError_OK
            }]);
            _loc2_.x = 450;
            _loc2_.y = 275;
         }
         else
         {
            end(null);
         }
      }
      
      private function onError_OK() : void
      {
         hideDlg();
         end(null);
      }
      
      public function resetGame() : void
      {
      }
      
      private function onResetDlg() : void
      {
         _soundMan.playByName(_soundNameReset);
         _theGame.loader.content.reset();
      }
      
      private function showDoneDlg() : void
      {
         if(_theGame.loader.content.cat9 != _theGame.loader.content.cat9original || _theGame.loader.content.cat10 != _theGame.loader.content.cat10original || _theGame.loader.content.cat11 != _theGame.loader.content.cat11original)
         {
            _theGame.loader.content.showConfirm = false;
            _theGame.loader.content.faceFront();
            _closeBtn.visible = false;
            _doneButton.visible = false;
            _resetButton.visible = false;
         }
         else
         {
            end(null);
         }
      }
      
      private function onCostClose() : void
      {
         stage.removeEventListener("keyDown",onCostCloseKeyDown);
         _theGame.loader.content.faceBack();
         _closeBtn.visible = true;
         _doneButton.visible = true;
         _resetButton.visible = true;
         hideDlg();
      }
      
      private function onDone_Yes() : void
      {
         stage.removeEventListener("keyDown",onConfirmKeyDown);
         hideDlg();
         _closeBtn.visible = false;
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.sendPetItemRequest(_theGame.loader.content.cat9,_theGame.loader.content.cat10,_theGame.loader.content.cat11,MinigameManager.roomEnviroType,petUpdated);
         _updatingPet = true;
      }
      
      private function onDone_No() : void
      {
         stage.removeEventListener("keyDown",onConfirmKeyDown);
         _theGame.loader.content.faceBack();
         hideDlg();
         _doneButton.visible = true;
         _resetButton.visible = true;
         _closeBtn.visible = true;
      }
      
      public function onCloseButton() : void
      {
         showExitConfirmationDlg();
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("PetSalon_areYouSure",[{
            "name":"yesBtn",
            "f":onExit_Yes
         },{
            "name":"noBtn",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _doneButton.visible = false;
         _resetButton.visible = false;
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         _doneButton.visible = true;
         _resetButton.visible = true;
      }
   }
}

