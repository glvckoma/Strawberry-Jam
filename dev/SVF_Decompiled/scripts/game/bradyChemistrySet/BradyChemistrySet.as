package game.bradyChemistrySet
{
   import achievement.AchievementXtCommManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class BradyChemistrySet extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static var SFX_BCS_beaker_bubble_lp:Class;
      
      public static var SFX_BCS_flame_lp:Class;
      
      private const _sounds:Array = ["bb_beaker_found_stinger.mp3","bb_bubble_over.mp3","bb_flame_start.mp3","bb_lever_turn.mp3","bb_steam_poof.mp3","bb_steam_sssss.mp3","bb_beaker_rollover.mp3","bb_beaker_Select.mp3"];
      
      private var _soundNameBeakerFound:String = _sounds[0];
      
      private var _soundNameBubbleOver:String = _sounds[1];
      
      private var _soundNameFlameStart:String = _sounds[2];
      
      private var _soundNameLeverTurn:String = _sounds[3];
      
      private var _soundNameSteamPoof:String = _sounds[4];
      
      private var _soundNameSteamSSSSS:String = _sounds[5];
      
      private var _soundNameBeakerRollover:String = _sounds[6];
      
      private var _soundNameBeakerSelect:String = _sounds[7];
      
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
      
      private var _SFX_BCS_beaker_bubble_lp:SoundChannel;
      
      private var _SFX_BCS_flame_lp:SoundChannel;
      
      public function BradyChemistrySet()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameBeakerFound],_soundNameBeakerFound,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameBubbleOver],_soundNameBubbleOver,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFlameStart],_soundNameFlameStart,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameLeverTurn],_soundNameLeverTurn,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameSteamPoof],_soundNameSteamPoof,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameSteamSSSSS],_soundNameSteamSSSSS,0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameBeakerRollover],_soundNameBeakerRollover,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameBeakerSelect],_soundNameBeakerSelect,0.2);
         _soundMan.addSound(SFX_BCS_beaker_bubble_lp,0.3,"SFX_BCS_beaker_bubble_lp");
         _soundMan.addSound(SFX_BCS_flame_lp,0.2,"SFX_BCS_flame_lp");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_SFX_BCS_beaker_bubble_lp)
         {
            _SFX_BCS_beaker_bubble_lp.stop();
            _SFX_BCS_beaker_bubble_lp = null;
         }
         if(_SFX_BCS_flame_lp)
         {
            _SFX_BCS_flame_lp.stop();
            _SFX_BCS_flame_lp = null;
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
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("BradyChemistrySet/room_main.xroom",_sounds);
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
         SFX_BCS_beaker_bubble_lp = getDefinitionByName("bb_beaker_bubble_lp") as Class;
         if(SFX_BCS_beaker_bubble_lp == null)
         {
            throw new Error("Sound not found! name:bb_beaker_bubble_lp");
         }
         SFX_BCS_flame_lp = getDefinitionByName("bb_flame_lp") as Class;
         if(SFX_BCS_flame_lp == null)
         {
            throw new Error("Sound not found! name:bb_flame_lp");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",761,77,onCloseButton);
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
                  if(_theGame.loader.content.beaker_bubble_lp)
                  {
                     if(!_SFX_BCS_beaker_bubble_lp)
                     {
                        _SFX_BCS_beaker_bubble_lp = _soundMan.play(SFX_BCS_beaker_bubble_lp,0,99999);
                     }
                  }
                  else if(_SFX_BCS_beaker_bubble_lp)
                  {
                     _SFX_BCS_beaker_bubble_lp.stop();
                     _SFX_BCS_beaker_bubble_lp = null;
                  }
                  if(_theGame.loader.content.beaker_found_stinger)
                  {
                     _theGame.loader.content.beaker_found_stinger = false;
                     _soundMan.playByName(_soundNameBeakerFound);
                  }
                  if(_theGame.loader.content.bubble_over)
                  {
                     _theGame.loader.content.bubble_over = false;
                     _soundMan.playByName(_soundNameBubbleOver);
                  }
                  if(_theGame.loader.content.flame_start)
                  {
                     _theGame.loader.content.flame_start = false;
                     _soundMan.playByName(_soundNameFlameStart);
                  }
                  if(_theGame.loader.content.lever_turn)
                  {
                     _theGame.loader.content.lever_turn = false;
                     _soundMan.playByName(_soundNameLeverTurn);
                  }
                  if(_theGame.loader.content.steam_poof)
                  {
                     _theGame.loader.content.steam_poof = false;
                     _soundMan.playByName(_soundNameSteamPoof);
                  }
                  if(_theGame.loader.content.steam_sssss)
                  {
                     _theGame.loader.content.steam_sssss = false;
                     _soundMan.playByName(_soundNameSteamSSSSS);
                  }
                  if(_theGame.loader.content.beaker_rollover)
                  {
                     _theGame.loader.content.beaker_rollover = false;
                     _soundMan.playByName(_soundNameBeakerRollover);
                  }
                  if(_theGame.loader.content.beaker_Select)
                  {
                     _theGame.loader.content.beaker_Select = false;
                     _soundMan.playByName(_soundNameBeakerSelect);
                  }
                  if(_theGame.loader.content.finished)
                  {
                     if(_theGame.loader.content.secretActivated)
                     {
                        if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                        {
                           AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
                        }
                     }
                     MinigameManager.msg(["_a",6,_theGame.loader.content.emoticonInfo]);
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

