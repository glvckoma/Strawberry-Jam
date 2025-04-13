package game.cottonCandy
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class CottonCandy extends GameBase implements IMinigame
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
      
      private const _sounds:Array = ["cc_cottonGet1.mp3","cc_cottonGet2.mp3","cc_cottonGet3.mp3","cc_cottonGet4.mp3","cc_cottonSelect.mp3","cc_cotton_Rollover.mp3","cc_cottonSpun.mp3","cc_enjoy.mp3","cc_spinnerCottonEnter.mp3","cc_conesEnter.mp3"];
      
      private var _soundNameCottonGet1:String = _sounds[0];
      
      private var _soundNameCottonGet2:String = _sounds[1];
      
      private var _soundNameCottonGet3:String = _sounds[2];
      
      private var _soundNameCottonGet4:String = _sounds[3];
      
      private var _soundNameCottonSelect:String = _sounds[4];
      
      private var _soundNameCottonRollover:String = _sounds[5];
      
      private var _soundNameCottonSpun:String = _sounds[6];
      
      private var _soundNameEnjoy:String = _sounds[7];
      
      private var _soundNameSpinnerCottonEnter:String = _sounds[8];
      
      private var _soundNameConesEnter:String = _sounds[9];
      
      public function CottonCandy()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameCottonGet1],_soundNameCottonGet1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonGet2],_soundNameCottonGet2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonGet3],_soundNameCottonGet3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonGet4],_soundNameCottonGet4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonSelect],_soundNameCottonSelect,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonRollover],_soundNameCottonRollover,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameCottonSpun],_soundNameCottonSpun,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameEnjoy],_soundNameEnjoy,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSpinnerCottonEnter],_soundNameSpinnerCottonEnter,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameConesEnter],_soundNameConesEnter,0.48);
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
            loadScene("CottonCandy/room_main.xroom",_sounds);
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
                  if(_theGame.loader.content.cottonGet1)
                  {
                     _theGame.loader.content.cottonGet1 = false;
                     _soundMan.playByName(_soundNameCottonGet1);
                  }
                  if(_theGame.loader.content.cottonGet2)
                  {
                     _theGame.loader.content.cottonGet2 = false;
                     _soundMan.playByName(_soundNameCottonGet2);
                  }
                  if(_theGame.loader.content.cottonGet3)
                  {
                     _theGame.loader.content.cottonGet3 = false;
                     _soundMan.playByName(_soundNameCottonGet3);
                  }
                  if(_theGame.loader.content.cottonGet4)
                  {
                     _theGame.loader.content.cottonGet4 = false;
                     _soundMan.playByName(_soundNameCottonGet4);
                  }
                  if(_theGame.loader.content.cottonSelect)
                  {
                     _theGame.loader.content.cottonSelect = false;
                     _soundMan.playByName(_soundNameCottonSelect);
                  }
                  if(_theGame.loader.content.cotton_Rollover)
                  {
                     _theGame.loader.content.cotton_Rollover = false;
                     _soundMan.playByName(_soundNameCottonRollover);
                  }
                  if(_theGame.loader.content.cottonSpun)
                  {
                     _theGame.loader.content.cottonSpun = false;
                     _soundMan.playByName(_soundNameCottonSpun);
                  }
                  if(_theGame.loader.content.enjoy)
                  {
                     _theGame.loader.content.enjoy = false;
                     _soundMan.playByName(_soundNameEnjoy);
                  }
                  if(_theGame.loader.content.spinnerCottonEnter)
                  {
                     _theGame.loader.content.spinnerCottonEnter = false;
                     _soundMan.playByName(_soundNameSpinnerCottonEnter);
                  }
                  if(_theGame.loader.content.conesEnter)
                  {
                     _theGame.loader.content.conesEnter = false;
                     _soundMan.playByName(_soundNameConesEnter);
                  }
                  if(_theGame.loader.content.finished)
                  {
                     MinigameManager.msg(["_a",30,_theGame.loader.content.emoticonInfo]);
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

