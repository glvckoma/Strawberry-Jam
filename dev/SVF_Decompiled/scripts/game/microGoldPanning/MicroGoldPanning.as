package game.microGoldPanning
{
   import achievement.AchievementXtCommManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class MicroGoldPanning extends GameBase implements IMinigame
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
      
      private var _audio:Array = ["ajq_goldPan1.mp3","ajq_goldPan2.mp3","ajq_goldPan3.mp3","ajq_goldPan4.mp3","ajq_miningStinger.mp3","ajq_textEnter.mp3","ajq_textExit.mp3","ajq_resourceMoving2Bag.mp3","ajq_resourceDrop.mp3","ajq_resourcePopupEnter.mp3","ajq_resourcePopUpExit.mp3","ajq_satchelClose.mp3","ajq_satchelOpen.mp3","ajq_panWaterDip.mp3"];
      
      private var _soundNameGoldPan1:String = _audio[0];
      
      private var _soundNameGoldPan2:String = _audio[1];
      
      private var _soundNameGoldPan3:String = _audio[2];
      
      private var _soundNameGoldPan4:String = _audio[3];
      
      private var _soundNameStinger:String = _audio[4];
      
      private var _soundNameTextEnter:String = _audio[5];
      
      private var _soundNameTextExit:String = _audio[6];
      
      private var _soundNameResourceMove:String = _audio[7];
      
      private var _soundNameResourceDrop:String = _audio[8];
      
      private var _soundNamePopupEnter:String = _audio[9];
      
      private var _soundNamePopupExit:String = _audio[10];
      
      private var _soundNameSatchelClose:String = _audio[11];
      
      private var _soundNameSatchelOpen:String = _audio[12];
      
      private var _soundNameWaterDip:String = _audio[13];
      
      public function MicroGoldPanning()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameGoldPan1],_soundNameGoldPan1,0.85);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldPan2],_soundNameGoldPan2,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldPan3],_soundNameGoldPan3,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldPan4],_soundNameGoldPan4,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger],_soundNameStinger,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameTextEnter],_soundNameTextEnter,1);
         _soundMan.addSoundByName(_audioByName[_soundNameTextExit],_soundNameTextExit,1.42);
         _soundMan.addSoundByName(_audioByName[_soundNameResourceMove],_soundNameResourceMove,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameResourceDrop],_soundNameResourceDrop,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupEnter],_soundNamePopupEnter,0.78);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupExit],_soundNamePopupExit,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameSatchelClose],_soundNameSatchelClose,0.73);
         _soundMan.addSoundByName(_audioByName[_soundNameSatchelOpen],_soundNameSatchelOpen,0.82);
         _soundMan.addSoundByName(_audioByName[_soundNameWaterDip],_soundNameWaterDip,0.5);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
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
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroGoldPanning/room_main.xroom",_audio);
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
                  if(_theGame.loader.content.gameFinished)
                  {
                     if(_closeBtn)
                     {
                        _closeBtn.visible = false;
                     }
                  }
                  if(_theGame.loader.content.ajq_textEnter)
                  {
                     _theGame.loader.content.ajq_textEnter = false;
                     _soundMan.playByName(_soundNameTextEnter);
                  }
                  if(_theGame.loader.content.ajq_textExit)
                  {
                     _theGame.loader.content.ajq_textExit = false;
                     _soundMan.playByName(_soundNameTextExit);
                  }
                  if(_theGame.loader.content.ajq_miningStinger)
                  {
                     _theGame.loader.content.ajq_miningStinger = false;
                     _soundMan.playByName(_soundNameStinger);
                  }
                  if(_theGame.loader.content.ajq_goldPan1)
                  {
                     _theGame.loader.content.ajq_goldPan1 = false;
                     _soundMan.playByName(_soundNameGoldPan1);
                  }
                  if(_theGame.loader.content.ajq_goldPan2)
                  {
                     _theGame.loader.content.ajq_goldPan2 = false;
                     _soundMan.playByName(_soundNameGoldPan2);
                  }
                  if(_theGame.loader.content.ajq_goldPan3)
                  {
                     _theGame.loader.content.ajq_goldPan3 = false;
                     _soundMan.playByName(_soundNameGoldPan3);
                  }
                  if(_theGame.loader.content.ajq_goldPan4)
                  {
                     _theGame.loader.content.ajq_goldPan4 = false;
                     _soundMan.playByName(_soundNameGoldPan4);
                  }
                  if(_theGame.loader.content.ajq_resourcePopupEnter)
                  {
                     _theGame.loader.content.ajq_resourcePopupEnter = false;
                     _soundMan.playByName(_soundNamePopupEnter);
                  }
                  if(_theGame.loader.content.ajq_resourcePopUpExit)
                  {
                     _theGame.loader.content.ajq_resourcePopUpExit = false;
                     _soundMan.playByName(_soundNamePopupExit);
                  }
                  if(_theGame.loader.content.ajq_resourceMoveToBag)
                  {
                     _theGame.loader.content.ajq_resourceMoveToBag = false;
                     _soundMan.playByName(_soundNameResourceMove);
                  }
                  if(_theGame.loader.content.ajq_resourceDrop)
                  {
                     _theGame.loader.content.ajq_resourceDrop = false;
                     _soundMan.playByName(_soundNameResourceDrop);
                  }
                  if(_theGame.loader.content.ajq_satchelClose)
                  {
                     _theGame.loader.content.ajq_satchelClose = false;
                     _soundMan.playByName(_soundNameSatchelClose);
                  }
                  if(_theGame.loader.content.ajq_satchelOpen)
                  {
                     _theGame.loader.content.ajq_satchelOpen = false;
                     _soundMan.playByName(_soundNameSatchelOpen);
                  }
                  if(_theGame.loader.content.ajq_panWaterDip)
                  {
                     _theGame.loader.content.ajq_panWaterDip = false;
                     _soundMan.playByName(_soundNameWaterDip);
                  }
                  if(_theGame.loader.content.finished)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
                     }
                     MinigameManager.handleQuestMiniGameComplete(_theGame.loader.content.reward);
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

