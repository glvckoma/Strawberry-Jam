package game.microHotCocoa
{
   import achievement.AchievementXtCommManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class MicroHotCocoa extends GameBase implements IMinigame
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
      
      public var _theGame:Object;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["aj_cocoa_button_select.mp3","aj_cocoa_condiment_enter.mp3","aj_cocoa_cup_option_enter.mp3","aj_cocoa_cup_option_exit.mp3","aj_cocoa_enjoy.mp3","aj_cocoa_lever_down.mp3","aj_cocoa_lever_enter.mp3","aj_cocoa_lever_stop.mp3","aj_cocoa_lever_up.mp3","aj_cocoa_pour_topping_enter.mp3","aj_cocoa_rollover.mp3","aj_cocoa_topping_select.mp3","aj_cocoa_vend_select_enter.mp3","aj_cocoa_marshmallow_splash.mp3","aj_cocoa_whipcream.mp3","aj_cocoa_lever_click.mp3"];
      
      private var _soundNameButtonSelect:String = _audio[0];
      
      private var _soundNameCondimentEnter:String = _audio[1];
      
      private var _soundNameCupOptionEnter:String = _audio[2];
      
      private var _soundNameCupOptionExit:String = _audio[3];
      
      private var _soundNameEnjoy:String = _audio[4];
      
      private var _soundNameLeverDown:String = _audio[5];
      
      private var _soundNameLeverEnter:String = _audio[6];
      
      private var _soundNameLeverStop:String = _audio[7];
      
      private var _soundNameLeverUp:String = _audio[8];
      
      private var _soundNamePourToppingEnter:String = _audio[9];
      
      private var _soundNameRollover:String = _audio[10];
      
      private var _soundNameToppingSelect:String = _audio[11];
      
      private var _soundNameVendSelectEnter:String = _audio[12];
      
      private var _soundNameMarshmallowSplash:String = _audio[13];
      
      private var _soundNameWhipCream:String = _audio[14];
      
      private var _soundNameLeverPull:String = _audio[15];
      
      private var _leverPullSound:SoundChannel;
      
      public function MicroHotCocoa()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameButtonSelect],_soundNameButtonSelect,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameCondimentEnter],_soundNameCondimentEnter,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameCupOptionEnter],_soundNameCupOptionEnter,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameCupOptionExit],_soundNameCupOptionExit,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameEnjoy],_soundNameEnjoy,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverDown],_soundNameLeverDown,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverEnter],_soundNameLeverEnter,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverStop],_soundNameLeverStop,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverUp],_soundNameLeverUp,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNamePourToppingEnter],_soundNamePourToppingEnter,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameToppingSelect],_soundNameToppingSelect,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameVendSelectEnter],_soundNameVendSelectEnter,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameMarshmallowSplash],_soundNameMarshmallowSplash,0.37);
         _soundMan.addSoundByName(_audioByName[_soundNameWhipCream],_soundNameWhipCream,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverPull],_soundNameLeverPull,0.95);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_leverPullSound)
         {
            _leverPullSound.stop();
            _leverPullSound = null;
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
         _leverPullSound = null;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroHotCocoa/room_main.xroom",_audio);
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
                  if(_theGame.loader.content.button_select)
                  {
                     _theGame.loader.content.button_select = false;
                     _soundMan.playByName(_soundNameButtonSelect);
                  }
                  if(_theGame.loader.content.condiment_enter)
                  {
                     _theGame.loader.content.condiment_enter = false;
                     _soundMan.playByName(_soundNameCondimentEnter);
                  }
                  if(_theGame.loader.content.cup_option_enter)
                  {
                     _theGame.loader.content.cup_option_enter = false;
                     _soundMan.playByName(_soundNameCupOptionEnter);
                  }
                  if(_theGame.loader.content.cup_option_exit)
                  {
                     _theGame.loader.content.cup_option_exit = false;
                     _soundMan.playByName(_soundNameCupOptionExit);
                  }
                  if(_theGame.loader.content.enjoy)
                  {
                     _theGame.loader.content.enjoy = false;
                     _soundMan.playByName(_soundNameEnjoy);
                  }
                  if(_theGame.loader.content.lever_down)
                  {
                     if(_leverPullSound)
                     {
                        _leverPullSound.stop();
                        _leverPullSound = null;
                     }
                     _leverPullSound = _soundMan.playByName(_soundNameLeverPull,0,5);
                     _theGame.loader.content.lever_down = false;
                  }
                  if(_theGame.loader.content.lever_up)
                  {
                     if(_leverPullSound)
                     {
                        _leverPullSound.stop();
                        _leverPullSound = null;
                     }
                     _leverPullSound = _soundMan.playByName(_soundNameLeverPull,0,5);
                     _theGame.loader.content.lever_up = false;
                  }
                  if(_theGame.loader.content.lever_stop)
                  {
                     if(_leverPullSound)
                     {
                        _leverPullSound.stop();
                        _leverPullSound = null;
                     }
                     _theGame.loader.content.lever_stop = false;
                     _soundMan.playByName(_soundNameLeverStop);
                  }
                  if(_theGame.loader.content.lever_enter)
                  {
                     _theGame.loader.content.lever_enter = false;
                     _soundMan.playByName(_soundNameLeverEnter);
                  }
                  if(_theGame.loader.content.pour_topping_enter)
                  {
                     _theGame.loader.content.pour_topping_enter = false;
                     _soundMan.playByName(_soundNamePourToppingEnter);
                  }
                  if(_theGame.loader.content.rollover)
                  {
                     _theGame.loader.content.rollover = false;
                     _soundMan.playByName(_soundNameRollover);
                  }
                  if(_theGame.loader.content.topping_select)
                  {
                     _theGame.loader.content.topping_select = false;
                     _soundMan.playByName(_soundNameToppingSelect);
                  }
                  if(_theGame.loader.content.vend_select_enter)
                  {
                     _theGame.loader.content.vend_select_enter = false;
                     _soundMan.playByName(_soundNameVendSelectEnter);
                  }
                  if(_theGame.loader.content.marshmallow_splash)
                  {
                     _theGame.loader.content.marshmallow_splash = false;
                     _soundMan.playByName(_soundNameMarshmallowSplash);
                  }
                  if(_theGame.loader.content.whipcream)
                  {
                     _theGame.loader.content.whipcream = false;
                     _soundMan.playByName(_soundNameWhipCream);
                  }
                  if(_theGame.loader.content.finished)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
                     }
                     MinigameManager.msg(["_a",5,_theGame.loader.content.cocoaInfo]);
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
         if(!_theGame)
         {
         }
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

