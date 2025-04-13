package game.microPetWash
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class MicroPetWash extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static var SFX_MICROPET_dispenser_lights_lp:Class;
      
      public static var SFX_MICROPET_water_dripping:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _sentSparkle:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _soundMan:SoundManager;
      
      public var _pet:Object;
      
      private var _audio:Array = ["aj_cart_rollout.mp3","aj_pw_brushes_fast.mp3","aj_pw_brushes_medium.mp3","aj_pw_brushes_slow.mp3","aj_pw_bubbleDispenser_lower.mp3","aj_pw_bubbles_released.mp3","aj_pw_chain_lower.mp3","aj_pw_petEnters.mp3","aj_pw_rinse.mp3","aj_pw_rinseAscend.mp3","aj_pw_spray.mp3","aj_pw_towelDry.mp3","aj_pw_wash_stinger.mp3","aj_pw_wash_select.mp3"];
      
      private var _soundNameCartRollout:String = _audio[0];
      
      private var _soundNameBrushesFast:String = _audio[1];
      
      private var _soundNameBrushesMedium:String = _audio[2];
      
      private var _soundNameBrushesSlow:String = _audio[3];
      
      private var _soundNameBubbleDispenserLower:String = _audio[4];
      
      private var _soundNameBubblesReleased:String = _audio[5];
      
      private var _soundNameChainLower:String = _audio[6];
      
      private var _soundNamePetEnters:String = _audio[7];
      
      private var _soundNameRinse:String = _audio[8];
      
      private var _soundNameRinseAscend:String = _audio[9];
      
      private var _soundNameSpray:String = _audio[10];
      
      private var _soundNameTowelDry:String = _audio[11];
      
      private var _soundNameWashStinger:String = _audio[12];
      
      private var _soundNameWashSelect:String = _audio[13];
      
      private var _SFX_MICROPET_dispenser_lights_lp_Instance:SoundChannel;
      
      private var _SFX_MICROPET_water_dripping_Instance:SoundChannel;
      
      public function MicroPetWash()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameCartRollout],_soundNameCartRollout,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameBrushesFast],_soundNameBrushesFast,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameBrushesMedium],_soundNameBrushesMedium,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBrushesSlow],_soundNameBrushesSlow,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameBubbleDispenserLower],_soundNameBubbleDispenserLower,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBubblesReleased],_soundNameBubblesReleased,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameChainLower],_soundNameChainLower,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePetEnters],_soundNamePetEnters,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNameRinse],_soundNameRinse,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameRinseAscend],_soundNameRinseAscend,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSpray],_soundNameSpray,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameTowelDry],_soundNameTowelDry,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameWashStinger],_soundNameWashStinger,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameWashSelect],_soundNameWashSelect,0.45);
         _soundMan.addSound(SFX_MICROPET_dispenser_lights_lp,0.45,"SFX_MICROPET_dispenser_lights_lp");
         _soundMan.addSound(SFX_MICROPET_water_dripping,0.6,"SFX_MICROPET_water_dripping");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_SFX_MICROPET_dispenser_lights_lp_Instance)
         {
            _SFX_MICROPET_dispenser_lights_lp_Instance.stop();
            _SFX_MICROPET_dispenser_lights_lp_Instance = null;
         }
         if(_SFX_MICROPET_water_dripping_Instance)
         {
            _SFX_MICROPET_water_dripping_Instance.stop();
            _SFX_MICROPET_water_dripping_Instance = null;
         }
         releaseBase();
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
         _SFX_MICROPET_dispenser_lights_lp_Instance = null;
         _SFX_MICROPET_water_dripping_Instance = null;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroPetWash/room_main.xroom",_audio);
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
         SFX_MICROPET_dispenser_lights_lp = getDefinitionByName("dispenser_lights_lp") as Class;
         if(SFX_MICROPET_dispenser_lights_lp == null)
         {
            throw new Error("Sound not found! name:dispenser_lights_lp");
         }
         SFX_MICROPET_water_dripping = getDefinitionByName("water_Dripping") as Class;
         if(SFX_MICROPET_water_dripping == null)
         {
            throw new Error("Sound not found! name:water_Dripping");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closebutton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _theGame = _scene.getLayer("thegame");
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
               if(_theGame && _theGame.loader && _theGame.loader.content)
               {
                  if(_theGame.loader.content.wash_stinger)
                  {
                     _theGame.loader.content.wash_stinger = false;
                     _soundMan.playByName(_soundNameWashStinger);
                  }
                  if(_theGame.loader.content.wash_select)
                  {
                     _theGame.loader.content.wash_select = false;
                     _soundMan.playByName(_soundNameWashSelect);
                  }
                  if(_theGame.loader.content.spray)
                  {
                     _theGame.loader.content.spray = false;
                     _soundMan.playByName(_soundNameSpray);
                  }
                  if(_theGame.loader.content.petEnters)
                  {
                     _theGame.loader.content.petEnters = false;
                     _soundMan.playByName(_soundNamePetEnters);
                  }
                  if(_theGame.loader.content.rinse)
                  {
                     _theGame.loader.content.rinse = false;
                     _soundMan.playByName(_soundNameRinse);
                  }
                  if(_theGame.loader.content.rinseAscend)
                  {
                     _theGame.loader.content.rinseAscend = false;
                     _soundMan.playByName(_soundNameRinseAscend);
                  }
                  if(_theGame.loader.content.towelDry)
                  {
                     _theGame.loader.content.towelDry = false;
                     _soundMan.playByName(_soundNameTowelDry);
                  }
                  if(_theGame.loader.content.cart_rollout)
                  {
                     _theGame.loader.content.cart_rollout = false;
                     _soundMan.playByName(_soundNameCartRollout);
                  }
                  if(_theGame.loader.content.brushes_fast)
                  {
                     _theGame.loader.content.brushes_fast = false;
                     _soundMan.playByName(_soundNameBrushesFast);
                  }
                  if(_theGame.loader.content.brushes_medium)
                  {
                     _theGame.loader.content.brushes_medium = false;
                     _soundMan.playByName(_soundNameBrushesMedium);
                  }
                  if(_theGame.loader.content.brushes_slow)
                  {
                     _theGame.loader.content.brushes_slow = false;
                     _soundMan.playByName(_soundNameBrushesSlow);
                  }
                  if(_theGame.loader.content.bubbleDispenser_lower)
                  {
                     _theGame.loader.content.bubbleDispenser_lower = false;
                     _soundMan.playByName(_soundNameBubbleDispenserLower);
                  }
                  if(_theGame.loader.content.bubbles_released)
                  {
                     _theGame.loader.content.bubbles_released = false;
                     _soundMan.playByName(_soundNameBubblesReleased);
                  }
                  if(_theGame.loader.content.chain_lower)
                  {
                     _theGame.loader.content.chain_lower = false;
                     _soundMan.playByName(_soundNameChainLower);
                  }
                  if(_theGame.loader.content.dispenser_lights_lp)
                  {
                     if(_SFX_MICROPET_dispenser_lights_lp_Instance == null)
                     {
                        _SFX_MICROPET_dispenser_lights_lp_Instance = _soundMan.play(SFX_MICROPET_dispenser_lights_lp,0,99999);
                     }
                  }
                  else if(_SFX_MICROPET_dispenser_lights_lp_Instance != null)
                  {
                     _SFX_MICROPET_dispenser_lights_lp_Instance.stop();
                     _SFX_MICROPET_dispenser_lights_lp_Instance = null;
                  }
                  if(_theGame.loader.content.water_dripping)
                  {
                     if(_SFX_MICROPET_water_dripping_Instance == null)
                     {
                        _SFX_MICROPET_water_dripping_Instance = _soundMan.play(SFX_MICROPET_water_dripping,0,99999);
                     }
                  }
                  else if(_SFX_MICROPET_water_dripping_Instance != null)
                  {
                     _SFX_MICROPET_water_dripping_Instance.stop();
                     _SFX_MICROPET_water_dripping_Instance = null;
                  }
                  if(!_sentSparkle && _theGame.loader.content.sparkleReady)
                  {
                     MinigameManager.setPetSparkle(_theGame.loader.content.effectInfo);
                     _sentSparkle = true;
                  }
                  if(_theGame.loader.content.finished)
                  {
                     end(null);
                  }
               }
            }
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
            _pet = MinigameManager.getActivePet(petLoaded);
            if(_pet == null)
            {
               _theGame.loader.content.setUpPet(null);
            }
         }
      }
      
      public function petLoaded(param1:MovieClip) : void
      {
         _theGame.loader.content.setUpPet(_pet);
         _pet.getChildAt(0).pet.setAnim(1);
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

