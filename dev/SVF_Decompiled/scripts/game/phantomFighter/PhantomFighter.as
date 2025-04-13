package game.phantomFighter
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.SoundChannel;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class PhantomFighter extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const GAMEOVER_POPUP_X:int = 450;
      
      private static const GAMEOVER_POPUP_Y:int = 275;
      
      private static const TILE_HEIGHT:int = 900;
      
      public static const MAX_ATTACK_TIME:int = 10;
      
      public static const MIN_PLAYER_X:int = 150;
      
      public static const MAX_PLAYER_X:int = 670;
      
      public static const MIN_PLAYER_Y:int = 320;
      
      public static const MAX_PLAYER_Y:int = 490;
      
      public static const MAX_PLAYER_VEL:Number = 14;
      
      public static const BACKGROUND_SPEED:int = 20;
      
      public static const BACKGROUND_SPEED_BOOST_MULTIPLIER:int = 15;
      
      public static const BACKGROUND_BOOST_DECELERATION:Number = 15;
      
      private static const PHANTOM_SHOT_MAX_VELOCITY:int = -250;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_STARTED:int = 2;
      
      public static const GAMESTATE_ENDED:int = 3;
      
      public static const SPAWN_POWERUP_TIME_INTERVAL_LOW:int = 30;
      
      public static const SPAWN_POWERUP_TIME_INTERVAL_HIGH:int = 90;
      
      public static const TIME_BETWEEN_WAVES:int = 2;
      
      public static const ENABLE_CLOUD_OVERLAY:Boolean = false;
      
      private var _phantomsLayoutRow:Array = [15,80,145,210,275];
      
      private var _phantomsLayoutColumn:Array = [175,231,286,314,342,397,425,453,508,536,564,619,675];
      
      private var _phantomsLayout:Array = [[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      }],[{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      }],[{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      }],[{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":0
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":0
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":0
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":9,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":9,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":725
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":3,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":3,
         "y":2
      },{
         "tile":"phantom",
         "x":3,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":9,
         "y":2
      },{
         "tile":"phantom",
         "x":9,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":435,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":9,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":6,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":6,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":0
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":0
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":3,
         "y":0
      },{
         "tile":"phantom",
         "x":3,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":9,
         "y":0
      },{
         "tile":"phantom",
         "x":9,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":0,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":5,
         "y":2
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":2
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":3
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]],[[{
         "tile":"phantom",
         "x":0,
         "y":2
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":4
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":4
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":12,
         "y":2
      }],[{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":0
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":1
      },{
         "tile":"phantom",
         "x":2,
         "y":4
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":6,
         "y":0
      },{
         "tile":"phantom",
         "x":6,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":10,
         "y":1
      },{
         "tile":"phantom",
         "x":10,
         "y":4
      },{
         "tile":"phantom",
         "x":11,
         "y":0
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":4
      },{
         "tile":"phantom",
         "x":1,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":2,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":1
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":3
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":10,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":1
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":4
      }],[{
         "tile":"phantom",
         "x":0,
         "y":0
      },{
         "tile":"phantom",
         "x":0,
         "y":1
      },{
         "tile":"phantom",
         "x":1,
         "y":2
      },{
         "tile":"phantom",
         "x":1,
         "y":3
      },{
         "tile":"phantom",
         "x":1,
         "y":4
      },{
         "tile":"phantom",
         "x":2,
         "y":0
      },{
         "tile":"phantom",
         "x":2,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":2
      },{
         "tile":"phantom",
         "x":4,
         "y":3
      },{
         "tile":"phantom",
         "x":4,
         "y":4
      },{
         "tile":"phantom",
         "x":5,
         "y":0
      },{
         "tile":"phantom",
         "x":5,
         "y":1
      },{
         "tile":"phantom",
         "x":7,
         "y":0
      },{
         "tile":"phantom",
         "x":7,
         "y":1
      },{
         "tile":"phantom",
         "x":8,
         "y":2
      },{
         "tile":"phantom",
         "x":8,
         "y":3
      },{
         "tile":"phantom",
         "x":8,
         "y":4
      },{
         "tile":"phantom",
         "x":10,
         "y":0
      },{
         "tile":"phantom",
         "x":10,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":2
      },{
         "tile":"phantom",
         "x":11,
         "y":3
      },{
         "tile":"phantom",
         "x":11,
         "y":4
      },{
         "tile":"phantom",
         "x":12,
         "y":0
      },{
         "tile":"phantom",
         "x":12,
         "y":1
      }],[{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      },{
         "tile":"phantom",
         "x":-10,
         "y":-10
      }]]];
      
      public var _phantomAttackData:Array = [{
         "low":5,
         "high":10,
         "attackChance":0.5,
         "redChance":0.05
      },{
         "low":4,
         "high":9,
         "attackChance":0.6,
         "redChance":0.1
      },{
         "low":3,
         "high":8,
         "attackChance":0.7,
         "redChance":0.2
      },{
         "low":3,
         "high":9,
         "attackChance":0.8,
         "redChance":0.35
      },{
         "low":3,
         "high":8,
         "attackChance":0.9,
         "redChance":0.5
      }];
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _levelSelectPopup:Object;
      
      public var _startLevelSelected:int;
      
      public var _levelSelectPopupTimer:Number;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _displayAchievementTimer:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerBackgroundYPos:Number;
      
      public var _layerBackgroundClouds:Sprite;
      
      public var _layerBackgroundCloudsYPos:Number;
      
      public var _layerPlayers:Sprite;
      
      public var _layerShots:Sprite;
      
      public var _layerLives:Sprite;
      
      public var _gameState:int;
      
      public var _player1:PhantomFighterPlayer;
      
      public var _backgrounds:Array;
      
      public var _activeBackgrounds:Array;
      
      public var _activeBackgrounds_cloud:Array;
      
      public var _phantoms:Array;
      
      public var _playerShots:Array;
      
      public var _playerShotsNormal:Array;
      
      public var _playerShotsPowerful:Array;
      
      public var _playerShotsExplosive:Array;
      
      public var _phantomShots:Array;
      
      public var _phantomShotsPool:Array;
      
      public var _powerups:Array;
      
      public var _level:int;
      
      public var _attackIndex:int;
      
      public var _score:int;
      
      public var _lives:int;
      
      public var _currentwave:int;
      
      public var _levelHUD:Object;
      
      public var _scoreHUD:Object;
      
      public var _respawnPlayerTime:Number;
      
      public var _targetPosX:Number;
      
      public var _targetPosY:Number;
      
      public var _leftArrow:Boolean;
      
      public var _rightArrow:Boolean;
      
      public var _upArrow:Boolean;
      
      public var _downArrow:Boolean;
      
      public var _space:Boolean;
      
      public var _spawnPowerupTimer:Number;
      
      public var _spawnNextWaveTimer:Number;
      
      public var _readyCountdownTimer:Number;
      
      public var _phantomsInFormation:Boolean;
      
      public var _playerCanShoot:Boolean;
      
      public var _levelTextTriggered:Boolean;
      
      public var _backgroundBoost:Number;
      
      public var _round:int;
      
      public var _playerRespawnShieldTimer:Number;
      
      public var _removeControls:Boolean;
      
      public var _soundMan:SoundManager;
      
      public var _phantomsDestroyed:int;
      
      public var _totalGems:int;
      
      private var _audio:Array = ["PF_Bomb_explode.mp3","PF_Bomb_Projectile_fire.mp3","PF_Electric_tornado_fire.mp3","PF_Phantom_Death.mp3","PF_Phantom_Fire.mp3","PF_Phantom_long_attack.mp3","PF_pickup.mp3","PF_turbo_3.9seconds.mp3","PF_veh_death.mp3","PF_veh_fire.mp3","PF_veh_player_ready3.mp3","PF_veh_shield_off.mp3","PF_veh_shield_on.mp3","GS_Ready_Level.mp3","GS_Level_next_level.mp3","hud_select.mp3","hud_roll_over.mp3"];
      
      internal var _soundNameBombExplode:String = _audio[0];
      
      internal var _soundNameBombProjectileFire:String = _audio[1];
      
      internal var _soundNameElectricTornadoFire:String = _audio[2];
      
      internal var _soundNamePhantomDeath:String = _audio[3];
      
      internal var _soundNamePhantomFire:String = _audio[4];
      
      internal var _soundNamePhantomLongAttack:String = _audio[5];
      
      internal var _soundNamePickup:String = _audio[6];
      
      internal var _soundNameTurboLong:String = _audio[7];
      
      internal var _soundNameVehDeath:String = _audio[8];
      
      internal var _soundNameVehFire:String = _audio[9];
      
      internal var _soundNameVehPlayerReady3:String = _audio[10];
      
      internal var _soundNameVehShieldOff:String = _audio[11];
      
      internal var _soundNameVehShieldOn:String = _audio[12];
      
      internal var _soundNameReadyLevel:String = _audio[13];
      
      internal var _soundNameNextLevel:String = _audio[14];
      
      internal var _soundNameHudSelect:String = _audio[15];
      
      internal var _soundNameHudRollover:String = _audio[16];
      
      public var _SFX_PF_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function PhantomFighter()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_PF_Music = _soundMan.addStream("AJ_Mus_Phantom_Fighter",0.61);
         _soundMan.addSoundByName(_audioByName[_soundNameBombExplode],_soundNameBombExplode,0.71);
         _soundMan.addSoundByName(_audioByName[_soundNameBombProjectileFire],_soundNameBombProjectileFire,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameElectricTornadoFire],_soundNameElectricTornadoFire,0.74);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDeath],_soundNamePhantomDeath,0.76);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomFire],_soundNamePhantomFire,0.46);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomLongAttack],_soundNamePhantomLongAttack,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePickup],_soundNamePickup,0.74);
         _soundMan.addSoundByName(_audioByName[_soundNameTurboLong],_soundNameTurboLong,0.66);
         _soundMan.addSoundByName(_audioByName[_soundNameVehDeath],_soundNameVehDeath,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameVehFire],_soundNameVehFire,0.71);
         _soundMan.addSoundByName(_audioByName[_soundNameVehPlayerReady3],_soundNameVehPlayerReady3,0.56);
         _soundMan.addSoundByName(_audioByName[_soundNameVehShieldOff],_soundNameVehShieldOff,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameVehShieldOn],_soundNameVehShieldOn,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameReadyLevel],_soundNameReadyLevel,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameNextLevel],_soundNameNextLevel,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameHudSelect],_soundNameHudSelect,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameHudRollover],_soundNameHudRollover,0.6);
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
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",nextLevelKeyDown);
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyboardPressed);
         stage.removeEventListener("keyUp",keyboardReleased);
         _bInit = false;
         _backgrounds = null;
         removeLayer(_layerBackground);
         removeLayer(_layerPlayers);
         removeLayer(_layerShots);
         removeLayer(_layerLives);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerBackgroundClouds = null;
         _layerPlayers = null;
         _layerShots = null;
         _layerLives = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            setGameState(0);
            _backgrounds = [];
            _layerBackground = new Sprite();
            _layerBackground.mouseEnabled = false;
            _layerBackgroundClouds = new Sprite();
            _layerBackgroundClouds.mouseEnabled = false;
            _layerPlayers = new Sprite();
            _layerShots = new Sprite();
            _layerLives = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerShots);
            addChild(_layerPlayers);
            addChild(_guiLayer);
            addChild(_layerLives);
            loadScene("PhantomFighterAssets/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function keyboardPressed(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = true;
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               _space = true;
               break;
            case 5:
               _leftArrow = true;
               break;
            case 6:
               _upArrow = true;
               break;
            case 7:
               _rightArrow = true;
               break;
            case 8:
               _downArrow = true;
               break;
            default:
               _loc2_ = false;
         }
         if(_removeControls && _loc2_)
         {
            _removeControls = false;
            _guiLayer.removeChild(_scene.getLayer("controls").loader);
         }
      }
      
      private function keyboardPressedDlg(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onNextLevel();
               stage.focus = this;
         }
      }
      
      private function keyboardReleased(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               _space = false;
               break;
            case 5:
               _leftArrow = false;
               break;
            case 6:
               _upArrow = false;
               break;
            case 7:
               _rightArrow = false;
               break;
            case 8:
               _downArrow = false;
         }
      }
      
      private function moveTargetPos() : void
      {
         if(_leftArrow)
         {
            _targetPosX -= 14;
            if(_targetPosX < 150)
            {
               _targetPosX = 150;
            }
         }
         else if(_rightArrow)
         {
            _targetPosX += 14;
            if(_targetPosX > 670)
            {
               _targetPosX = 670;
            }
         }
         if(_upArrow)
         {
            _targetPosY -= 14;
            if(_targetPosY < 320)
            {
               _targetPosY = 320;
            }
         }
         else if(_downArrow)
         {
            _targetPosY += 14;
            if(_targetPosY > 490)
            {
               _targetPosY = 490;
            }
         }
      }
      
      override protected function hideDlg() : void
      {
         super.hideDlg();
         stage.stageFocusRect = false;
         stage.focus = this;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:String = null;
         var _loc3_:Object = null;
         if(stage == null)
         {
            trace("ERROR: sceneLoaded but stage is null?!");
            return;
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_PF_Music,0,999999);
         _loc5_ = 1;
         while(_loc5_ <= 16)
         {
            _loc4_ = "background_" + _loc5_;
            _loc3_ = _scene.getLayer(_loc4_);
            if(_loc3_)
            {
               _loc6_ = {};
               _loc6_.name = _loc4_;
               _loc6_.clone = _loc3_.loader;
               _backgrounds.push(_loc6_);
            }
            _loc5_++;
         }
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",keyboardPressed);
         stage.addEventListener("keyUp",keyboardReleased);
         _levelSelectPopupTimer = 0;
         _levelSelectPopup = _scene.getLayer("levelSelect");
         _levelSelectPopup.loader.x = 0;
         _levelSelectPopup.loader.y = 0;
         _guiLayer.addChild(_levelSelectPopup.loader);
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         super.sceneLoaded(param1);
      }
      
      public function setGameState(param1:int) : void
      {
         if(_gameState != param1)
         {
            _gameState = param1;
         }
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "ml")
         {
            end(param1);
            return;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc12_:Object = null;
         var _loc15_:* = null;
         var _loc17_:Boolean = false;
         var _loc4_:Dictionary = null;
         var _loc14_:Object = null;
         var _loc20_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:int = 0;
         var _loc7_:Object = null;
         var _loc23_:String = null;
         var _loc10_:int = 0;
         var _loc13_:Object = null;
         var _loc3_:* = NaN;
         var _loc19_:* = 0;
         var _loc22_:Number = NaN;
         var _loc2_:int = 0;
         var _loc21_:MovieClip = null;
         var _loc16_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_levelSelectPopup)
            {
               if(_levelSelectPopup.loader.content.hud_select)
               {
                  _levelSelectPopup.loader.content.hud_select = false;
                  _soundMan.playByName(_soundNameHudSelect);
               }
               if(_levelSelectPopup.loader.content.hud_rollover)
               {
                  _levelSelectPopup.loader.content.hud_rollover = false;
                  _soundMan.playByName(_soundNameHudRollover);
               }
               if(_levelSelectPopupTimer > 0)
               {
                  _levelSelectPopupTimer -= _frameTime;
                  if(_levelSelectPopupTimer <= 0)
                  {
                     _guiLayer.removeChild(_levelSelectPopup.loader);
                     _levelSelectPopup = null;
                     startGame();
                     if(_closeBtn)
                     {
                        _guiLayer.removeChild(_closeBtn);
                        _guiLayer.addChild(_closeBtn);
                     }
                     else
                     {
                        _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
                     }
                     stage.stageFocusRect = false;
                     stage.focus = this;
                  }
               }
               else if(_levelSelectPopup.loader.content.introOn == false)
               {
                  if(_levelSelectPopup.loader.content.difficulty == "medium")
                  {
                     _startLevelSelected = 10;
                  }
                  else if(_levelSelectPopup.loader.content.difficulty == "hard")
                  {
                     _startLevelSelected = 20;
                  }
                  else
                  {
                     _startLevelSelected = 1;
                  }
                  _levelSelectPopupTimer = 0.01;
               }
            }
            else if(!_pauseGame && _gameState == 2)
            {
               _gameTime += _frameTime;
               if(_displayAchievementTimer > 0)
               {
                  _displayAchievementTimer -= _frameTime;
                  if(_displayAchievementTimer <= 0)
                  {
                     AchievementManager.displayNewAchievements();
                  }
               }
               if(_readyCountdownTimer > 0)
               {
                  _readyCountdownTimer -= _frameTime;
                  if(_readyCountdownTimer <= 0)
                  {
                     _readyCountdownTimer = 0;
                     _levelTextTriggered = false;
                     _guiLayer.removeChild(_scene.getLayer("ready").loader);
                     _guiLayer.addChild(_scene.getLayer("level_text").loader);
                     _scene.getLayer("level_text").loader.content.gotoAndPlay(0);
                     LocalizationManager.translateIdAndInsert(_scene.getLayer("level_text").loader.content.Level.level,11548,_level - _startLevelSelected + 1);
                     _soundMan.playByName(_soundNameNextLevel);
                  }
               }
               else
               {
                  if(_respawnPlayerTime == 0)
                  {
                     _player1.heartbeat(_frameTime);
                     if(_phantomsInFormation)
                     {
                        if(_playerRespawnShieldTimer > 0)
                        {
                           _playerRespawnShieldTimer -= _frameTime;
                           if(_playerRespawnShieldTimer <= 0)
                           {
                              _playerRespawnShieldTimer = 0;
                           }
                        }
                        if(_playerRespawnShieldTimer == 0)
                        {
                           if(_player1._clone.loader.content.shieldOnOff == true)
                           {
                              _player1._clone.loader.content.shieldOff();
                              _soundMan.playByName(_soundNameVehShieldOff);
                              _playerCanShoot = true;
                           }
                        }
                        if(_space)
                        {
                           _player1.shoot();
                        }
                     }
                     else if(_player1._clone.loader.content.shieldOnOff == false)
                     {
                        _player1._clone.loader.content.shieldOn();
                        _soundMan.playByName(_soundNameVehShieldOn);
                        _playerCanShoot = false;
                     }
                  }
                  else
                  {
                     _respawnPlayerTime -= _frameTime;
                     if(_respawnPlayerTime <= 0)
                     {
                        _respawnPlayerTime = 0;
                        revivePlayer();
                     }
                  }
                  if(_phantomsInFormation && _levelTextTriggered == false)
                  {
                     _scene.getLayer("level_text").loader.content.gotoAndPlay("fadeout");
                     _levelTextTriggered = true;
                     _player1._clone.loader.content.shieldOff();
                  }
                  _spawnPowerupTimer -= _frameTime;
                  if(_spawnPowerupTimer <= 0)
                  {
                     _spawnPowerupTimer = Math.random() * (90 - 30) + 30;
                     _loc12_ = {};
                     if(_powerups && _powerups.length > 0)
                     {
                        _loc12_.clone = _scene.cloneAsset("powerup");
                        _loc12_.clone.loader.contentLoaderInfo.addEventListener("complete",onPowerupLoaderComplete);
                     }
                     else
                     {
                        _loc12_.clone = _scene.getLayer("powerup");
                        setRandomPowerupType(_loc12_.clone.loader);
                     }
                     _loc12_.height = _scene.getLayer("powerup").loader.content.height;
                     _loc12_.clone.loader.x = Math.random() * (670 - 150) + 150;
                     _loc12_.clone.loader.y = -_loc12_.height - _layerBackground.y;
                     _powerups.push(_loc12_);
                     _layerBackground.addChild(_loc12_.clone.loader);
                  }
                  _loc17_ = false;
                  if(_phantoms)
                  {
                     _loc4_ = new Dictionary(true);
                     if(_respawnPlayerTime == 0 && _phantomShots && _playerRespawnShieldTimer == 0)
                     {
                        _loc5_ = _phantomShots.length - 1;
                        while(_loc5_ >= 0)
                        {
                           _loc14_ = _phantomShots[_loc5_];
                           if(boxCollisionTest(_loc14_.clone.loader.x,_loc14_.clone.loader.y,_loc14_.clone.loader.width,_loc14_.clone.loader.height,_player1._clone.loader.x,_player1._clone.loader.y,_player1._clone.loader.content.collision.width,_player1._clone.loader.content.collision.height))
                           {
                              _player1.die();
                              KillPlayer();
                              _loc14_.clone.loader.parent.removeChild(_loc14_.clone.loader);
                              deactivateShot(_phantomShots[_loc5_]);
                              _phantomShots.splice(_loc5_,1);
                           }
                           _loc5_--;
                        }
                     }
                     if(_spawnNextWaveTimer == 0)
                     {
                        _phantomsInFormation = true;
                     }
                     for each(_loc15_ in _phantoms)
                     {
                        if(_loc15_ && _loc15_.active)
                        {
                           _loc17_ = true;
                        }
                        if(_loc15_.clone.loader.content)
                        {
                           if(_loc15_.startTimer > 0)
                           {
                              _loc15_.startTimer -= _frameTime;
                              if(_loc15_.startTimer <= 0)
                              {
                                 _loc8_ = 1;
                                 if(Math.random() < _phantomAttackData[_attackIndex].redChance)
                                 {
                                    _loc8_ = 2;
                                 }
                                 _loc15_.clone.loader.visible = true;
                                 _loc15_.clone.loader.content.levelStart(1,1,_loc8_,"right");
                                 _loc15_.color = _loc8_;
                              }
                              else
                              {
                                 _phantomsInFormation = false;
                              }
                           }
                           else
                           {
                              if(_loc15_.clone.loader.content.entering == true && _loc15_.active)
                              {
                                 _phantomsInFormation = false;
                              }
                              _loc7_ = _loc15_.clone.loader.getChildAt(0);
                              if(_loc7_)
                              {
                                 _loc20_ = _loc15_.clone.loader.x + _loc7_.phantom.x - 25;
                                 _loc18_ = _loc15_.clone.loader.y + _loc7_.phantom.y - 16;
                                 _loc11_ = 43;
                                 _loc6_ = 30;
                                 if(_loc15_.active)
                                 {
                                    if(_respawnPlayerTime == 0)
                                    {
                                       if(_loc15_.attackTimer > 0)
                                       {
                                          _loc15_.attackTimer -= _frameTime;
                                          if(_loc15_.attackTimer <= 0)
                                          {
                                             if(_playerCanShoot == true && Math.random() < _phantomAttackData[_attackIndex].attackChance)
                                             {
                                                if(_loc15_.clone.loader.x < 320)
                                                {
                                                   _loc23_ = "left";
                                                }
                                                else if(_loc15_.clone.loader.x < 480)
                                                {
                                                   _loc23_ = "center";
                                                }
                                                else
                                                {
                                                   _loc23_ = "right";
                                                }
                                                _loc15_.clone.loader.content.attack(1,1,_loc23_);
                                                _loc15_.attackSound = _soundMan.playByName(_soundNamePhantomLongAttack);
                                             }
                                             _loc15_.attackTimer = getRandomAttackTime();
                                          }
                                       }
                                       if(_loc15_.shootTimer > 0)
                                       {
                                          _loc15_.shootTimer -= _frameTime;
                                          if(_loc15_.shootTimer <= 0)
                                          {
                                             if(_playerCanShoot == true && Math.random() < _phantomAttackData[_attackIndex].attackChance)
                                             {
                                                _loc15_.clone.loader.content.shoot();
                                                _soundMan.playByName(_soundNamePhantomFire);
                                                _loc10_ = 5;
                                                _loc13_ = getNewShot(_loc10_);
                                                _loc13_.clone.loader.x = _loc15_.clone.loader.x;
                                                _loc13_.clone.loader.y = _loc15_.clone.loader.y + _loc7_.phantom.y + 15;
                                                _loc13_.velocity = -250;
                                                _loc13_.type = _loc10_;
                                                if(_loc15_.color != 1)
                                                {
                                                   if(_loc13_.clone.loader.content == null)
                                                   {
                                                      _loc13_.clone.loader.contentLoaderInfo.addEventListener("complete",onPhantomProjectileLoaderComplete);
                                                   }
                                                   else
                                                   {
                                                      _loc13_.clone.loader.content.colorChange(2);
                                                   }
                                                }
                                                addPhantomShot(_loc13_);
                                             }
                                             _loc15_.shootTimer = getRandomAttackTime();
                                          }
                                       }
                                       if(_respawnPlayerTime == 0 && _loc15_.clone.loader.content.attacking == true && _playerRespawnShieldTimer == 0)
                                       {
                                          if(boxCollisionTest(_loc20_,_loc18_,_loc11_,_loc6_,_player1._clone.loader.x,_player1._clone.loader.y,_player1._clone.loader.content.collision.width,_player1._clone.loader.content.collision.height))
                                          {
                                             _player1.die();
                                             KillPlayer();
                                          }
                                       }
                                    }
                                    if(_playerShots && _playerCanShoot)
                                    {
                                       _loc5_ = _playerShots.length - 1;
                                       while(_loc5_ >= 0 && _loc15_.active && _playerShots[_loc5_].clone.loader.content)
                                       {
                                          if(boxCollisionTest(_loc20_,_loc18_,_loc11_,_loc6_,_playerShots[_loc5_].clone.loader.x + _playerShots[_loc5_].clone.loader.content.collision.x,_playerShots[_loc5_].clone.loader.y + _playerShots[_loc5_].clone.loader.content.collision.y,_playerShots[_loc5_].clone.loader.content.collision.width,_playerShots[_loc5_].clone.loader.content.collision.height,_playerShots[_loc5_].lastPosX,_playerShots[_loc5_].lastPosY))
                                          {
                                             if(_playerShots[_loc5_].type != 3 || _playerShots[_loc5_].clone.loader.content.explosionState != 2)
                                             {
                                                if(_playerShots[_loc5_].type != 1 && _playerShots[_loc5_].type != 3)
                                                {
                                                   if(_loc4_[_playerShots[_loc5_]] == null)
                                                   {
                                                      _loc4_[_playerShots[_loc5_]] = [];
                                                   }
                                                   _loc4_[_playerShots[_loc5_]].push(_loc15_);
                                                }
                                                else
                                                {
                                                   hitPhantom(_loc15_);
                                                }
                                             }
                                             switch(_playerShots[_loc5_].type)
                                             {
                                                case 1:
                                                   break;
                                                case 3:
                                                   if(_playerShots[_loc5_].clone.loader.content.explosionState == 0)
                                                   {
                                                      _playerShots[_loc5_].clone.loader.content.gotoAndPlay("on");
                                                      _soundMan.playByName(_soundNameBombExplode);
                                                   }
                                                   break;
                                                default:
                                                   _playerShots.splice(_loc5_,1);
                                             }
                                          }
                                          _loc5_--;
                                       }
                                    }
                                 }
                              }
                           }
                        }
                     }
                     for(var _loc24_ in _loc4_)
                     {
                        if(_loc4_[_loc24_].length > 1)
                        {
                           _loc3_ = 5000;
                           _loc19_ = 0;
                           _loc5_ = 0;
                           while(_loc5_ < _loc4_[_loc24_].length)
                           {
                              _loc22_ = Number(_loc4_[_loc24_][_loc5_].clone.loader.y);
                              if(_loc22_ < _loc3_)
                              {
                                 _loc3_ = _loc22_;
                                 _loc19_ = _loc5_;
                              }
                              _loc5_++;
                           }
                           hitPhantom(_loc4_[_loc24_][_loc19_],_loc24_);
                        }
                        else
                        {
                           hitPhantom(_loc4_[_loc24_][0],_loc24_);
                        }
                     }
                  }
                  if(_powerups)
                  {
                     if(_respawnPlayerTime == 0)
                     {
                        _loc5_ = 0;
                        while(_loc5_ < _powerups.length)
                        {
                           if(boxCollisionTest(_powerups[_loc5_].clone.loader.x,_powerups[_loc5_].clone.loader.y + _layerBackground.y,_powerups[_loc5_].clone.width,_powerups[_loc5_].clone.height,_player1._clone.loader.x,_player1._clone.loader.y,_player1._clone.loader.content.collision.width,_player1._clone.loader.content.collision.height))
                           {
                              _soundMan.playByName(_soundNamePickup);
                              _player1.upgrade(_powerups[_loc5_].clone.loader.content.powerupType);
                              _powerups[_loc5_].clone.loader.parent.removeChild(_powerups[_loc5_].clone.loader);
                              _powerups.splice(_loc5_,1);
                              IncrementScore(500);
                              _loc5_--;
                           }
                           _loc5_++;
                        }
                     }
                  }
                  if(_spawnNextWaveTimer == 0)
                  {
                     if(_backgroundBoost < 15 && _backgroundBoost > 1)
                     {
                        _backgroundBoost -= 15 * _frameTime;
                        if(_backgroundBoost < 1)
                        {
                           _backgroundBoost = 1;
                        }
                     }
                     if(!_loc17_)
                     {
                        _currentwave++;
                        _loc2_ = (_level - 1) % _phantomsLayout.length;
                        if(_currentwave == _phantomsLayout[_loc2_].length - 1)
                        {
                           _currentwave = 0;
                           if(_activeBackgrounds[1].clone.loader.y + _layerBackground.y + _activeBackgrounds[1].clone.loader.height < 0)
                           {
                              _activeBackgrounds[1].clone.loader.parent.removeChild(_activeBackgrounds[1].clone.loader);
                              _activeBackgrounds[1].clone.loader.unloadAndStop();
                              _activeBackgrounds.splice(1,1);
                           }
                           _spawnNextWaveTimer = -2;
                        }
                        else
                        {
                           _spawnNextWaveTimer = 2;
                        }
                     }
                  }
                  else if(_spawnNextWaveTimer > 0)
                  {
                     _spawnNextWaveTimer -= _frameTime;
                     if(_spawnNextWaveTimer <= 0)
                     {
                        _spawnNextWaveTimer = 0;
                        _player1.setBoost(false);
                        SpawnNewPhantomLayout();
                        if(_backgroundBoost > 1)
                        {
                           _backgroundBoost -= 15 * _frameTime;
                        }
                     }
                  }
                  else
                  {
                     _spawnNextWaveTimer += _frameTime;
                     if(_spawnNextWaveTimer >= 0)
                     {
                        IncrementScore(1000);
                        _spawnNextWaveTimer = 0;
                        stage.addEventListener("keyDown",nextLevelKeyDown);
                        _loc21_ = showDlg("Great_Job_PF",[{
                           "name":"button_nextlevel",
                           "f":onNextLevel
                        }]);
                        LocalizationManager.translateIdAndInsert(_loc21_.text_hit,11633,_phantomsDestroyed);
                        stage.stageFocusRect = false;
                        stage.focus = _loc21_;
                        _loc21_.addEventListener("keyDown",keyboardPressedDlg);
                        _loc16_ = Math.floor(_score / 1000) * 3 - _totalGems;
                        addGemsToBalance(_loc16_);
                        LocalizationManager.translateIdAndInsert(_loc21_.Gems_Earned,11554,_loc16_);
                        _totalGems = Math.floor(_score / 1000) * 3;
                        LocalizationManager.translateIdAndInsert(_loc21_.Gems_Total,11549,_totalGems);
                        _loc21_.x = 450;
                        _loc21_.y = 275;
                     }
                  }
                  moveShots(_playerShots);
                  moveShots(_phantomShots);
                  moveTargetPos();
               }
               moveBackground();
            }
         }
      }
      
      private function hitPhantom(param1:Object, param2:Object = null) : void
      {
         if(param1.color == 2)
         {
            param1.color = 1;
            param1.clone.loader.content.colorChange(1);
            param1.clone.loader.content.hit();
            if(param2)
            {
               param2.clone.loader.parent.removeChild(param2.clone.loader);
               deactivateShot(param2);
            }
         }
         else if(param1.active)
         {
            _soundMan.playByName(_soundNamePhantomDeath);
            param1.clone.loader.content.die();
            param1.clone.loader.content.attacks.stop();
            param1.clone.loader.content.stop();
            param1.active = false;
            IncrementScore(100);
            _phantomsDestroyed++;
            if(param1.attackSound)
            {
               _soundMan.stop(param1.attackSound);
            }
            if(param2)
            {
               param2.clone.loader.parent.removeChild(param2.clone.loader);
               deactivateShot(param2);
            }
         }
         else if(param2)
         {
            _playerShots.push(param2);
         }
      }
      
      private function revivePlayer() : void
      {
         _player1.revive();
         _soundMan.playByName(_soundNameVehPlayerReady3);
         _player1.upgrade("normal");
         _player1._clone.loader.content.shieldOn();
         _soundMan.playByName(_soundNameVehShieldOn);
         _playerRespawnShieldTimer = 2;
         _targetPosX = _player1._clone.loader.x;
         _targetPosY = _player1._clone.loader.y;
      }
      
      private function moveShots(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc2_:int = 0;
         if(param1)
         {
            _loc2_ = param1.length - 1;
            while(_loc2_ >= 0)
            {
               if(param1[_loc2_].clone.loader.y <= -50 || param1[_loc2_].clone.loader.y >= 600)
               {
                  param1[_loc2_].clone.loader.parent.removeChild(param1[_loc2_].clone.loader);
                  deactivateShot(param1[_loc2_]);
                  param1.splice(_loc2_,1);
               }
               else
               {
                  if(param1[_loc2_].lastPosX && param1[_loc2_].clone.loader.content)
                  {
                     param1[_loc2_].lastPosX = param1[_loc2_].clone.loader.x;
                     param1[_loc2_].lastPosY = param1[_loc2_].clone.loader.y;
                  }
                  _loc4_ = param1[_loc2_].clone.loader.content;
                  if(_loc4_ && _loc4_.explosionState && _loc4_.explosionState != 0)
                  {
                     _loc3_ = 0;
                  }
                  else
                  {
                     _loc3_ = 1;
                  }
                  if(param1[_loc2_].angle && param1[_loc2_].angle != 0)
                  {
                     param1[_loc2_].clone.loader.x += param1[_loc2_].velocity * _frameTime * 0.3 * param1[_loc2_].angle;
                     param1[_loc2_].clone.loader.y -= param1[_loc2_].velocity * _frameTime * 0.5;
                  }
                  else if(_loc3_)
                  {
                     param1[_loc2_].clone.loader.y -= param1[_loc2_].velocity * _frameTime;
                  }
               }
               _loc2_--;
            }
         }
      }
      
      private function deactivateShot(param1:Object) : void
      {
         switch(param1.type)
         {
            case 0:
            case 2:
            case 4:
               _playerShotsNormal.push(param1);
               break;
            case 1:
               _playerShotsPowerful.push(param1);
               break;
            case 3:
               _playerShotsExplosive.push(param1);
               break;
            case 5:
               _phantomShotsPool.push(param1);
         }
      }
      
      public function startGame() : void
      {
         var _loc3_:Object = null;
         _activeBackgrounds = [];
         _activeBackgrounds_cloud = [];
         _level = _startLevelSelected;
         _score = 0;
         _lives = 3;
         _round = 0;
         _attackIndex = 0;
         _phantomsDestroyed = 0;
         _totalGems = 0;
         _respawnPlayerTime = 0;
         _spawnNextWaveTimer = 0;
         _readyCountdownTimer = 3;
         _backgroundBoost = 1;
         _playerRespawnShieldTimer = 0;
         _spawnPowerupTimer = Math.random() * (90 - 30) + 30;
         var _loc2_:int = (_level - 1) % _backgrounds.length;
         _loc3_ = {};
         _loc3_.clone = _scene.cloneAsset(_backgrounds[_loc2_].name);
         _loc3_.height = _backgrounds[_loc2_].clone.content.height;
         _loc3_.clone.loader.y = -_loc3_.height + 550;
         _activeBackgrounds.push(_loc3_);
         _layerBackground.addChild(_loc3_.clone.loader);
         _loc3_ = {};
         _loc3_.clone = _scene.getLayer("border1");
         _guiLayer.addChild(_loc3_.clone.loader);
         _loc3_ = {};
         _loc3_.clone = _scene.getLayer("border2");
         _loc3_.clone.loader.scaleX = -1;
         _loc3_.clone.loader.x += _scene.getLayer("border2").loader.width;
         _guiLayer.addChild(_loc3_.clone.loader);
         _scoreHUD = {};
         _scoreHUD.clone = _scene.getLayer("score");
         _scoreHUD.clone.loader.content.score_box.score.text = String(_score);
         _guiLayer.addChild(_scoreHUD.clone.loader);
         _levelHUD = {};
         _levelHUD.clone = _scene.getLayer("level");
         _levelHUD.clone.loader.content.Level_Box.level.text = "0" + (String(_level - _startLevelSelected + 1));
         _levelHUD.clone.loader.contentLoaderInfo.addEventListener("complete",onLevelLoaderComplete);
         _guiLayer.addChild(_levelHUD.clone.loader);
         _guiLayer.addChild(_scene.getLayer("ready").loader);
         _guiLayer.addChild(_scene.getLayer("controls").loader);
         _removeControls = true;
         _soundMan.playByName(_soundNameReadyLevel);
         _loc3_ = {};
         _loc3_.clone = _scene.getLayer("ships");
         _guiLayer.addChild(_loc3_.clone.loader);
         _layerLives.addChild(_scene.getLayer("ships1").loader);
         _layerLives.addChild(_scene.getLayer("ships2").loader);
         _layerLives.addChild(_scene.getLayer("ships3").loader);
         _layerBackground.x = 0;
         _layerBackground.y = 0;
         _layerBackgroundClouds.x = 0;
         _layerBackgroundClouds.y = 0;
         _layerBackgroundYPos = 0;
         _layerBackgroundCloudsYPos = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         SpawnPlayer();
         _phantoms = [];
         _playerShots = [];
         _playerShotsNormal = [];
         _playerShotsPowerful = [];
         _playerShotsExplosive = [];
         _phantomShots = [];
         _phantomShotsPool = [];
         _powerups = [];
         SpawnNewPhantomLayout();
         setGameState(2);
      }
      
      public function restartGame(param1:int) : void
      {
         SpawnPlayer();
         SpawnNewPhantomLayout();
      }
      
      private function setGameOver(param1:Boolean) : void
      {
         if(_gameState != 3)
         {
            if(param1)
            {
            }
            setGameState(3);
         }
      }
      
      public function onScoreLoaderComplete(param1:Event) : void
      {
         param1.target.content.score_box.score.text = String(_score);
         param1.target.removeEventListener("complete",onScoreLoaderComplete);
      }
      
      public function onLevelLoaderComplete(param1:Event) : void
      {
         param1.target.content.Level_Box.level.text = "0" + (String(_level - _startLevelSelected + 1));
         param1.target.removeEventListener("complete",onLevelLoaderComplete);
      }
      
      public function onPhantomProjectileLoaderComplete(param1:Event) : void
      {
         param1.target.content.colorChange(2);
         param1.target.removeEventListener("complete",onPhantomProjectileLoaderComplete);
      }
      
      public function onPowerupLoaderComplete(param1:Event) : void
      {
         setRandomPowerupType(param1.target);
         param1.target.removeEventListener("complete",onPowerupLoaderComplete);
      }
      
      public function setRandomPowerupType(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = Math.floor(Math.random() * 4);
         switch(_loc3_)
         {
            case 0:
               _loc2_ = "powerful";
               break;
            case 1:
               _loc2_ = "triple";
               break;
            case 2:
               _loc2_ = "explosive";
               break;
            case 3:
               _loc2_ = "rapid";
         }
         param1.content.changeType(_loc2_);
      }
      
      public function addPlayerShot(param1:Object) : void
      {
         _layerShots.addChild(param1.clone.loader);
         _playerShots.push(param1);
      }
      
      public function getNewShot(param1:int) : Object
      {
         var _loc2_:Object = null;
         switch(param1)
         {
            case 0:
            case 2:
            case 4:
               if(_playerShotsNormal.length > 0)
               {
                  return _playerShotsNormal.splice(0,1)[0];
               }
               _loc2_ = {};
               _loc2_.clone = _scene.cloneAsset("projectile");
               return _loc2_;
               break;
            case 1:
               if(_playerShotsPowerful.length > 0)
               {
                  return _playerShotsPowerful.splice(0,1)[0];
               }
               _loc2_ = {};
               _loc2_.clone = _scene.cloneAsset("projectile_powerful");
               return _loc2_;
               break;
            case 3:
               if(_playerShotsExplosive.length > 0)
               {
                  return _playerShotsExplosive.splice(0,1)[0];
               }
               _loc2_ = {};
               _loc2_.clone = _scene.cloneAsset("projectile_explosive");
               return _loc2_;
               break;
            case 5:
               if(_phantomShotsPool.length > 0)
               {
                  _phantomShotsPool[0].clone.loader.content.colorChange(1);
                  return _phantomShotsPool.splice(0,1)[0];
               }
               _loc2_ = {};
               _loc2_.clone = _scene.cloneAsset("phantom_shot");
               return _loc2_;
               break;
            default:
               return null;
         }
      }
      
      private function addPhantomShot(param1:Object) : void
      {
         _layerShots.addChild(param1.clone.loader);
         _phantomShots.push(param1);
      }
      
      private function mouseClickHandler(param1:MouseEvent) : void
      {
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         if(_levelSelectPopup && _levelSelectPopup.loader.content)
         {
            _levelSelectPopup.loader.content.introPaused = true;
         }
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         if(_levelSelectPopup && _levelSelectPopup.loader.content)
         {
            _levelSelectPopup.loader.content.introPaused = false;
         }
      }
      
      private function IncrementScore(param1:int) : void
      {
         _score += param1;
         _scoreHUD.clone.loader.content.score_box.score.text = _score;
      }
      
      private function KillPlayer() : void
      {
         _lives--;
         if(_lives < 0)
         {
            showGameOverDlg(false);
         }
         else
         {
            _layerLives.removeChildAt(0);
            _respawnPlayerTime = 4;
         }
      }
      
      private function SpawnPlayer() : void
      {
         _player1 = new PhantomFighterPlayer(this);
         _player1.init();
         _soundMan.playByName(_soundNameVehPlayerReady3);
         _targetPosX = _player1._clone.loader.x;
         _targetPosY = _player1._clone.loader.y;
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onRetry_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function nextLevelKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onNextLevel();
         }
      }
      
      private function showGameOverDlg(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            stage.addEventListener("keyDown",nextLevelKeyDown);
            _loc2_ = showDlg("Great_Job_PF",[{
               "name":"Btn_Next",
               "f":onNextLevel
            }]);
            _loc2_.score.text = _score;
         }
         else
         {
            stage.addEventListener("keyDown",replayKeyDown);
            _loc2_ = showDlg("Game_Over",[{
               "name":"button_yes",
               "f":onRetry_Yes
            },{
               "name":"button_no",
               "f":onExit_Yes
            }]);
            addGemsToBalance(Math.floor(_score / 1000) * 3 - _totalGems);
            LocalizationManager.translateIdAndInsert(_loc2_.text_score,11432,Math.floor(_score / 1000) * 3);
         }
         _loc2_.x = 450;
         _loc2_.y = 275;
      }
      
      private function onNextLevel() : void
      {
         var _loc1_:int = 0;
         stage.removeEventListener("keyDown",nextLevelKeyDown);
         hideDlg();
         _level++;
         _player1._levelsWithNoDeath++;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(85,_player1._levelsWithNoDeath);
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,_level - _startLevelSelected + 1);
            _displayAchievementTimer = 1;
         }
         _levelHUD.clone.loader.content.Level_Box.level.text = "0" + (String(_level - _startLevelSelected + 1));
         var _loc3_:Number = (_level - 1) / _phantomsLayout.length;
         _attackIndex = Math.min(_phantomAttackData.length - 1,Math.floor(_loc3_ * _phantomAttackData.length));
         _phantomsDestroyed = 0;
         _levelTextTriggered = false;
         _phantomsInFormation = false;
         _scene.getLayer("level_text").loader.content.gotoAndPlay(0);
         LocalizationManager.translateIdAndInsert(_scene.getLayer("level_text").loader.content.Level.level,11548,_level - _startLevelSelected + 1);
         _soundMan.playByName(_soundNameNextLevel);
         var _loc4_:Object = {};
         _loc4_.clone = _scene.getLayer("transition_top");
         _loc4_.clone.loader.x = 154;
         _loc4_.clone.loader.y = -_layerBackground.y - 900;
         _loc1_ = int(_loc4_.clone.loader.y);
         _layerBackground.addChild(_loc4_.clone.loader);
         _loc4_.clone = _scene.getLayer("transition_mid");
         _loc4_.clone.loader.x = 154;
         _loc4_.clone.loader.y = _loc1_ + _scene.getLayer("transition_top").loader.height;
         _loc1_ = int(_loc4_.clone.loader.y);
         _layerBackground.addChild(_loc4_.clone.loader);
         _loc4_.clone = _scene.getLayer("transition_bot");
         _loc4_.clone.loader.x = 154;
         _loc4_.clone.loader.y = _loc1_ + _scene.getLayer("transition_mid").loader.height;
         _layerBackground.addChild(_loc4_.clone.loader);
         var _loc2_:int = (_level - 1) % _backgrounds.length;
         _loc4_ = {};
         _loc4_.clone = _scene.cloneAsset(_backgrounds[_loc2_].name);
         _loc4_.height = _backgrounds[_loc2_].clone.content.height;
         _loc4_.clone.loader.y = -_layerBackground.y - 900 - _scene.getLayer("transition_top").loader.height;
         _loc1_ = int(_loc4_.clone.loader.y);
         _activeBackgrounds.push(_loc4_);
         _layerBackground.addChildAt(_loc4_.clone.loader,_layerBackground.numChildren - 3);
         _loc4_ = {};
         _loc4_.clone = _scene.cloneAsset(_backgrounds[_loc2_].name);
         _loc4_.height = _backgrounds[_loc2_].clone.content.height;
         _loc4_.clone.loader.y = _loc1_ - _loc4_.height;
         _activeBackgrounds.push(_loc4_);
         _layerBackground.addChildAt(_loc4_.clone.loader,_layerBackground.numChildren - 3);
         _player1.setBoost(true);
         _backgroundBoost = 15;
         _soundMan.playByName(_soundNameTurboLong);
         _spawnNextWaveTimer = 1.3 * 900 / (20 * _backgroundBoost);
      }
      
      private function onRetry_Yes() : void
      {
         var _loc1_:* = null;
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         _level = _startLevelSelected - 1;
         _lives = 3;
         _round = 0;
         _phantomsDestroyed = 0;
         _totalGems = 0;
         _currentwave = 0;
         _spawnPowerupTimer = 0;
         _player1.Retry();
         revivePlayer();
         _soundMan.playByName(_soundNameVehPlayerReady3);
         IncrementScore(-_score);
         _layerLives.addChild(_scene.getLayer("ships1").loader);
         _layerLives.addChild(_scene.getLayer("ships2").loader);
         _layerLives.addChild(_scene.getLayer("ships3").loader);
         if(_phantoms)
         {
            for each(_loc1_ in _phantoms)
            {
               if(_loc1_.clone.loader.parent)
               {
                  _loc1_.clone.loader.parent.removeChild(_loc1_.clone.loader);
                  _loc1_.active = false;
               }
            }
         }
         if(_playerShots)
         {
            for each(_loc1_ in _playerShots)
            {
               if(_loc1_.clone.loader.parent)
               {
                  _loc1_.clone.loader.parent.removeChild(_loc1_.clone.loader);
               }
            }
            _playerShots = [];
         }
         if(_phantomShots)
         {
            for each(_loc1_ in _phantomShots)
            {
               if(_loc1_.clone.loader.parent)
               {
                  _loc1_.clone.loader.parent.removeChild(_loc1_.clone.loader);
               }
            }
            _phantomShots = [];
         }
         if(_powerups)
         {
            for each(_loc1_ in _powerups)
            {
               if(_loc1_.clone.loader.parent)
               {
                  _loc1_.clone.loader.parent.removeChild(_loc1_.clone.loader);
               }
            }
            _powerups = [];
         }
         onNextLevel();
      }
      
      private function SpawnNewPhantomLayout() : void
      {
         var _loc5_:Object = null;
         var _loc2_:* = null;
         var _loc1_:Boolean = false;
         var _loc4_:int = 0;
         var _loc3_:Number = 0.25;
         if(_phantoms)
         {
            for each(_loc2_ in _phantoms)
            {
               if(_loc2_.clone.loader.parent)
               {
                  _loc2_.clone.loader.parent.removeChild(_loc2_.clone.loader);
               }
            }
         }
         var _loc6_:int = (_level - 1) % _phantomsLayout.length;
         _round = (_level - 1) / _phantomsLayout.length;
         _loc4_ = 0;
         while(_loc4_ < _phantomsLayout[_loc6_][_currentwave].length)
         {
            _loc1_ = false;
            if(_loc4_ == _phantoms.length)
            {
               _loc5_ = {};
               _loc5_.clone = _scene.cloneAsset("phantom");
               _loc1_ = true;
            }
            else
            {
               _loc5_ = _phantoms[_loc4_];
               _loc5_.clone.loader.content.revive();
            }
            _loc5_.clone.loader.x = _phantomsLayoutColumn[_phantomsLayout[_loc6_][_currentwave][_loc4_].x];
            _loc5_.clone.loader.y = _phantomsLayoutRow[_phantomsLayout[_loc6_][_currentwave][_loc4_].y];
            _loc5_.active = true;
            _layerPlayers.addChild(_loc5_.clone.loader);
            _loc5_.clone.loader.visible = false;
            _loc5_.attackTimer = getRandomAttackTime();
            _loc5_.shootTimer = getRandomAttackTime();
            _loc5_.startTimer = _loc3_;
            _loc3_ += 0.25;
            if(_loc1_)
            {
               _phantoms.push(_loc5_);
            }
            _loc4_++;
         }
      }
      
      private function getRandomAttackTime() : Number
      {
         var _loc1_:Object = _phantomAttackData[_attackIndex];
         return Math.random() * (_loc1_.high - _loc1_.low) + _loc1_.low;
      }
      
      private function boxCollisionTest(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Object = null, param10:Object = null) : Boolean
      {
         var _loc21_:* = NaN;
         var _loc20_:* = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc14_:* = NaN;
         var _loc15_:* = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc22_:int = 0;
         var _loc19_:int = 0;
         if(param9 != null)
         {
            _loc24_ = param9 as Number;
            var _loc25_:Number = param10 as Number;
            _loc26_ = Math.abs(param5 - _loc24_);
            _loc13_ = Math.abs(param6 - _loc25_);
            _loc18_ = 0;
            _loc23_ = 0;
            if(_loc26_ > _loc13_)
            {
               _loc22_ = Math.ceil(_loc26_ / param7);
            }
            else
            {
               _loc22_ = Math.ceil(_loc13_ / param8);
            }
            if(_loc22_ > 0)
            {
               _loc18_ = (param5 - _loc24_) / _loc22_;
               _loc23_ = (param6 - _loc25_) / _loc22_;
            }
            if(_loc18_ == 0)
            {
               _loc21_ = param1;
               _loc20_ = param5;
               _loc16_ = param1 + param3;
               _loc17_ = param5 + param7;
               if(_loc16_ < _loc20_)
               {
                  return false;
               }
               if(_loc21_ > _loc17_)
               {
                  return false;
               }
            }
            if(_loc23_ == 0)
            {
               _loc14_ = param2;
               _loc15_ = param6;
               _loc12_ = param2 + param4;
               _loc11_ = param6 + param8;
               if(_loc12_ < _loc15_)
               {
                  return false;
               }
               if(_loc14_ > _loc11_)
               {
                  return false;
               }
            }
            _loc19_ = 0;
            while(_loc19_ < _loc22_)
            {
               _loc21_ = param1;
               _loc20_ = _loc24_;
               _loc16_ = param1 + param3;
               _loc17_ = _loc24_ + param7;
               _loc14_ = param2;
               _loc15_ = _loc25_;
               _loc12_ = param2 + param4;
               _loc11_ = _loc25_ + param8;
               _loc24_ += _loc18_;
               _loc25_ += _loc23_;
               if(_loc12_ >= _loc15_)
               {
                  if(_loc14_ <= _loc11_)
                  {
                     if(_loc16_ >= _loc20_)
                     {
                        if(_loc21_ <= _loc17_)
                        {
                           return true;
                        }
                     }
                  }
               }
               _loc19_++;
            }
         }
         _loc21_ = param1;
         _loc20_ = param5;
         _loc16_ = param1 + param3;
         _loc17_ = param5 + param7;
         _loc14_ = param2;
         _loc15_ = param6;
         _loc12_ = param2 + param4;
         _loc11_ = param6 + param8;
         if(_loc12_ < _loc15_)
         {
            return false;
         }
         if(_loc14_ > _loc11_)
         {
            return false;
         }
         if(_loc16_ < _loc20_)
         {
            return false;
         }
         if(_loc21_ > _loc17_)
         {
            return false;
         }
         return true;
      }
      
      private function moveBackground() : void
      {
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc1_:Loader = null;
         var _loc4_:int = 0;
         var _loc3_:Number = 20 * _frameTime * _backgroundBoost;
         _layerBackgroundYPos += 20 * _frameTime * _backgroundBoost;
         _layerBackground.y = Math.floor(_layerBackgroundYPos);
         if(_layerBackground.y > 1000)
         {
            _layerBackground.y -= 1000;
            _layerBackgroundYPos = _layerBackground.y;
            _loc2_ = 0;
            while(_loc2_ < _layerBackground.numChildren)
            {
               _layerBackground.getChildAt(_loc2_).y = _layerBackground.getChildAt(_loc2_).y + 1000;
               _loc2_++;
            }
         }
         if(_layerBackgroundClouds.y > 1000)
         {
            _layerBackgroundClouds.y -= 1000;
            _layerBackgroundCloudsYPos = _layerBackgroundClouds.y;
            for each(_loc5_ in _activeBackgrounds_cloud)
            {
               _loc5_.clone.loader.y += 1000;
            }
         }
         _loc2_ = _activeBackgrounds.length - 1;
         while(_loc2_ >= 0)
         {
            if(_activeBackgrounds[_loc2_].clone.loader.y + _layerBackground.y > 550)
            {
               _activeBackgrounds[_loc2_].clone.loader.unloadAndStop();
               _activeBackgrounds.splice(_loc2_,1);
            }
            _loc2_--;
         }
         _loc2_ = _powerups.length - 1;
         while(_loc2_ >= 0)
         {
            if(_powerups[_loc2_].clone.loader.y + _layerBackground.y > 550)
            {
               _powerups.splice(_loc2_,1);
            }
            _loc2_--;
         }
         _loc2_ = _activeBackgrounds_cloud.length - 1;
         while(_loc2_ >= 0)
         {
            if(_activeBackgrounds_cloud[_loc2_].clone.loader.y + _layerBackgroundClouds.y > 550)
            {
               _activeBackgrounds_cloud[_loc2_].clone.loader.parent.removeChild(_activeBackgrounds_cloud[_loc2_].clone.loader);
               _activeBackgrounds_cloud[_loc2_].clone.loader.unloadAndStop();
               _activeBackgrounds_cloud.splice(_loc2_,1);
            }
            _loc2_--;
         }
         _loc2_ = 0;
         while(_loc2_ < _layerBackground.numChildren)
         {
            if(_layerBackground.getChildAt(_loc2_).y + _layerBackground.y > 550)
            {
               _loc1_ = _layerBackground.getChildAt(_loc2_) as Loader;
               _layerBackground.removeChildAt(_loc2_);
               _loc2_--;
            }
            _loc2_++;
         }
         if(_activeBackgrounds.length == 1)
         {
            _loc5_ = {};
            _loc4_ = (_level - 1) % _backgrounds.length;
            _loc5_.clone = _scene.cloneAsset(_backgrounds[_loc4_].name);
            _loc5_.height = _backgrounds[_loc4_].clone.content.height;
            _loc5_.clone.loader.y = _activeBackgrounds[0].clone.loader.y - _loc5_.height;
            _activeBackgrounds.push(_loc5_);
            _layerBackground.addChildAt(_loc5_.clone.loader,0);
         }
         if(_activeBackgrounds_cloud.length == 1 && false)
         {
            _loc5_ = {};
            _loc5_.clone = _scene.cloneAsset("clouds");
            _loc5_.height = _scene.getLayer("clouds").loader.content.height;
            _loc5_.clone.loader.y = _activeBackgrounds_cloud[0].clone.loader.y - _loc5_.height;
            _activeBackgrounds_cloud.push(_loc5_);
            _layerBackgroundClouds.addChild(_loc5_.clone.loader);
         }
      }
   }
}

