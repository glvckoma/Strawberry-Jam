package game.twister
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class Twister extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_STARTED:int = 2;
      
      public static const GAMESTATE_GAMEOVER:int = 3;
      
      public static const GAMESTATE_SUCCESS:int = 4;
      
      public static const GAMESTATE_FAIL:int = 5;
      
      public static const BACKGROUND_SPEED:int = 0;
      
      public static const MAX_OBJECTS_ON_SCREEN_PER_TYPE:int = 5;
      
      public static const SCROLL_SPEED_OFFSET:int = 40;
      
      public static const NUM_OBSTACLE_TYPES:int = 15;
      
      public static const NUM_BACKGROUND_TYPES:int = 3;
      
      public static const NUM_STARTRAILS:int = 20;
      
      public static const DELAY_START:int = 5;
      
      public static const MAX_GEM_PAYOUT:int = 150;
      
      public static const GAME_SUCCESS_DELAY:int = 6;
      
      public static const TORNADO_FADE_TIME:Number = 1.5;
      
      public var _playerMovesHorizontally:Boolean = false;
      
      private var _twisterLayout:Array = [{
         "type":7,
         "x":262,
         "y":314,
         "v":-3,
         "rotationRate":-50,
         "flip":0
      },{
         "type":6,
         "x":605,
         "y":373,
         "v":-1,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":860,
         "y":254,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":878,
         "y":377,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":6,
         "x":893,
         "y":55,
         "v":-2,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":1160,
         "y":176,
         "v":-2,
         "rotationRate":60,
         "flip":0
      },{
         "type":6,
         "x":1345,
         "y":366,
         "v":-1,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":1430,
         "y":44,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":9,
         "x":1778,
         "y":302,
         "v":0,
         "rotationRate":-5,
         "flip":0
      },{
         "type":5,
         "x":1835,
         "y":-51,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":1870,
         "y":141,
         "v":-3,
         "rotationRate":-45,
         "flip":0
      },{
         "type":4,
         "x":2072,
         "y":511,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":2123,
         "y":55,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":2175,
         "y":372,
         "v":-2,
         "rotationRate":60,
         "flip":0
      },{
         "type":4,
         "x":2189,
         "y":149,
         "v":0,
         "rotationRate":-2,
         "flip":0
      },{
         "type":8,
         "x":2237,
         "y":374,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":2345,
         "y":-86,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":6,
         "x":2396,
         "y":290,
         "v":-2,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":2448,
         "y":406,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":5,
         "x":2557,
         "y":515,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":15,
         "x":2567,
         "y":210,
         "v":-2,
         "rotationRate":8,
         "flip":0
      },{
         "type":12,
         "x":2589,
         "y":76,
         "v":-1,
         "rotationRate":5,
         "flip":0
      },{
         "type":0,
         "x":2766,
         "y":57,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":7,
         "x":2853,
         "y":317,
         "v":-3,
         "rotationRate":60,
         "flip":0
      },{
         "type":6,
         "x":2864,
         "y":526,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":2912,
         "y":402,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":12,
         "x":2913,
         "y":-54,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":6,
         "x":2913,
         "y":131,
         "v":-1,
         "rotationRate":0,
         "flip":0
      },{
         "type":5,
         "x":3078,
         "y":66,
         "v":-2,
         "rotationRate":5,
         "flip":0
      },{
         "type":7,
         "x":3111,
         "y":535,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":3145,
         "y":288,
         "v":-1,
         "rotationRate":60,
         "flip":0
      },{
         "type":13,
         "x":3322,
         "y":498,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":7,
         "x":3365,
         "y":-25,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":3442,
         "y":376,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":3516,
         "y":246,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":15,
         "x":3557,
         "y":524,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":7,
         "x":3654,
         "y":105,
         "v":-2,
         "rotationRate":50,
         "flip":0
      },{
         "type":5,
         "x":3701,
         "y":-70,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":3751,
         "y":493,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":15,
         "x":3873,
         "y":402,
         "v":-2,
         "rotationRate":-35,
         "flip":0
      },{
         "type":9,
         "x":3947,
         "y":104,
         "v":0,
         "rotationRate":2,
         "flip":0
      },{
         "type":6,
         "x":4115,
         "y":-15,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":4125,
         "y":61,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":4142,
         "y":269,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":4154,
         "y":516,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":4229,
         "y":29,
         "v":0,
         "rotationRate":-4,
         "flip":0
      },{
         "type":15,
         "x":4442,
         "y":-30,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":4462,
         "y":517,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":8,
         "x":4475,
         "y":94,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":4688,
         "y":164,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":4712,
         "y":484,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":4814,
         "y":-24,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":4880,
         "y":36,
         "v":-1,
         "rotationRate":5,
         "flip":0
      },{
         "type":7,
         "x":4912,
         "y":401,
         "v":-2,
         "rotationRate":60,
         "flip":0
      },{
         "type":4,
         "x":5030,
         "y":176,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":14,
         "x":5140,
         "y":285,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":5254,
         "y":64,
         "v":-1,
         "rotationRate":5,
         "flip":0
      },{
         "type":5,
         "x":5405,
         "y":-64,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":5440,
         "y":70,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":5506,
         "y":-76,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":10,
         "x":5519,
         "y":5,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":5800,
         "y":60,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":5837,
         "y":440,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":5874,
         "y":145,
         "v":-1,
         "rotationRate":-5,
         "flip":0
      },{
         "type":8,
         "x":5922,
         "y":241,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":5946,
         "y":-21,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":6055,
         "y":317,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":6243,
         "y":-44,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":6287,
         "y":186,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":6292,
         "y":43,
         "v":-3,
         "rotationRate":60,
         "flip":0
      },{
         "type":12,
         "x":6354,
         "y":239,
         "v":-2,
         "rotationRate":-12,
         "flip":0
      },{
         "type":15,
         "x":6409,
         "y":517,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":6437,
         "y":28,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":10,
         "x":6504,
         "y":75,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":6,
         "x":6686,
         "y":451,
         "v":-2,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":6739,
         "y":50,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":8,
         "x":6835,
         "y":282,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":14,
         "x":6882,
         "y":-209,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":7039,
         "y":409,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":7117,
         "y":189,
         "v":0,
         "rotationRate":-2,
         "flip":0
      },{
         "type":10,
         "x":7254,
         "y":302,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":7292,
         "y":-70,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":7403,
         "y":33,
         "v":-1,
         "rotationRate":-10,
         "flip":0
      },{
         "type":3,
         "x":7443,
         "y":0,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":7509,
         "y":385,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":2,
         "x":7561,
         "y":333,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":7622,
         "y":124,
         "v":0,
         "rotationRate":-5,
         "flip":0
      },{
         "type":0,
         "x":7704,
         "y":55,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":8,
         "x":7823,
         "y":244,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":7939,
         "y":186,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":10,
         "x":8000,
         "y":-157,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":8053,
         "y":63,
         "v":0,
         "rotationRate":-2,
         "flip":0
      },{
         "type":4,
         "x":8141,
         "y":299,
         "v":0,
         "rotationRate":0,
         "flip":1
      },{
         "type":0,
         "x":8149,
         "y":59,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":8170,
         "y":405,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":8214,
         "y":-87,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":5,
         "x":8353,
         "y":419,
         "v":-2,
         "rotationRate":-5,
         "flip":0
      },{
         "type":10,
         "x":8407,
         "y":170,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":8424,
         "y":-16,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":8428,
         "y":523,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":8536,
         "y":62,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":8691,
         "y":494,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":8719,
         "y":-51,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":8843,
         "y":410,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":3,
         "x":8863,
         "y":252,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":8922,
         "y":17,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":14,
         "x":8981,
         "y":318,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":8,
         "x":8994,
         "y":-48,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":9157,
         "y":-92,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":9258,
         "y":453,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":9299,
         "y":100,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":2,
         "x":9478,
         "y":365,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":9524,
         "y":50,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":10,
         "x":9735,
         "y":227,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":5,
         "x":9834,
         "y":22,
         "v":-1,
         "rotationRate":-10,
         "flip":0
      },{
         "type":3,
         "x":9879,
         "y":172,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":9974,
         "y":427,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":9977,
         "y":66,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":10077,
         "y":184,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":10164,
         "y":-1,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":8,
         "x":10256,
         "y":-39,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":10338,
         "y":391,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":10414,
         "y":474,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":10474,
         "y":144,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":10516,
         "y":-303,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":10533,
         "y":399,
         "v":-2,
         "rotationRate":30,
         "flip":0
      },{
         "type":4,
         "x":10684,
         "y":177,
         "v":0,
         "rotationRate":-5,
         "flip":0
      },{
         "type":1,
         "x":10713,
         "y":390,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":10722,
         "y":205,
         "v":0,
         "rotationRate":5,
         "flip":0
      },{
         "type":10,
         "x":10804,
         "y":114,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":10845,
         "y":344,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":10958,
         "y":498,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":10997,
         "y":-61,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":11054,
         "y":396,
         "v":-1,
         "rotationRate":-12,
         "flip":0
      },{
         "type":5,
         "x":11094,
         "y":207,
         "v":0,
         "rotationRate":2,
         "flip":0
      },{
         "type":13,
         "x":11119,
         "y":262,
         "v":-3,
         "rotationRate":60,
         "flip":0
      },{
         "type":8,
         "x":11191,
         "y":159,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":11296,
         "y":70,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":11315,
         "y":146,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":11345,
         "y":-48,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":11446,
         "y":70,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":14,
         "x":11547,
         "y":-145,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":11597,
         "y":377,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":13,
         "x":11673,
         "y":444,
         "v":-2,
         "rotationRate":-60,
         "flip":0
      },{
         "type":0,
         "x":11732,
         "y":383,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":10,
         "x":11739,
         "y":229,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":11806,
         "y":-18,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":6,
         "x":11825,
         "y":504,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":8,
         "x":11907,
         "y":322,
         "v":0,
         "rotationRate":-1,
         "flip":0
      },{
         "type":5,
         "x":12014,
         "y":100,
         "v":0,
         "rotationRate":2,
         "flip":0
      },{
         "type":9,
         "x":12029,
         "y":135,
         "v":0,
         "rotationRate":-5,
         "flip":0
      },{
         "type":10,
         "x":12065,
         "y":364,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":12129,
         "y":52,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":12246,
         "y":3,
         "v":0,
         "rotationRate":-6,
         "flip":0
      },{
         "type":3,
         "x":12263,
         "y":145,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":12393,
         "y":265,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":11,
         "x":12401,
         "y":384,
         "v":-3,
         "rotationRate":-50,
         "flip":0
      },{
         "type":8,
         "x":12610,
         "y":41,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":12659,
         "y":164,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":12693,
         "y":-44,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":12794,
         "y":372,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":12802,
         "y":48,
         "v":-1,
         "rotationRate":15,
         "flip":0
      },{
         "type":0,
         "x":12868,
         "y":78,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":1,
         "x":12896,
         "y":-209,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":9,
         "x":12955,
         "y":387,
         "v":0,
         "rotationRate":-5,
         "flip":0
      },{
         "type":10,
         "x":13033,
         "y":310,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":13124,
         "y":52,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":3,
         "x":13163,
         "y":242,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":10,
         "x":13290,
         "y":119,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":12,
         "x":13356,
         "y":444,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":13453,
         "y":-51,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":0,
         "x":13477,
         "y":360,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":2,
         "x":13555,
         "y":325,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":5,
         "x":13585,
         "y":-26,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":14,
         "x":13644,
         "y":-74,
         "v":0,
         "rotationRate":0,
         "flip":0
      },{
         "type":4,
         "x":14156,
         "y":343,
         "v":-2,
         "rotationRate":-12,
         "flip":0
      },{
         "type":15,
         "x":14199,
         "y":108,
         "v":-2,
         "rotationRate":35,
         "flip":0
      },{
         "type":103,
         "x":-12,
         "y":505,
         "v":4,
         "flip":0
      },{
         "type":102,
         "x":503,
         "y":492,
         "v":3,
         "flip":0
      },{
         "type":103,
         "x":972,
         "y":500,
         "v":4,
         "flip":0
      },{
         "type":103,
         "x":1143,
         "y":506,
         "v":3,
         "flip":0
      },{
         "type":101,
         "x":1203,
         "y":419,
         "v":2,
         "flip":0
      },{
         "type":103,
         "x":1791,
         "y":505,
         "v":4,
         "flip":0
      },{
         "type":102,
         "x":2116,
         "y":478,
         "v":3,
         "flip":0
      },{
         "type":103,
         "x":2171,
         "y":505,
         "v":4,
         "flip":0
      },{
         "type":101,
         "x":3217,
         "y":459,
         "v":3,
         "flip":0
      },{
         "type":102,
         "x":4178,
         "y":491,
         "v":4,
         "flip":0
      },{
         "type":102,
         "x":4693,
         "y":497,
         "v":4,
         "flip":0
      },{
         "type":102,
         "x":5848,
         "y":506,
         "v":3,
         "flip":0
      },{
         "type":101,
         "x":6475,
         "y":417,
         "v":2,
         "flip":0
      },{
         "type":103,
         "x":7271,
         "y":503,
         "v":3,
         "flip":0
      },{
         "type":102,
         "x":8143,
         "y":484,
         "v":4,
         "flip":0
      },{
         "type":102,
         "x":8635,
         "y":462,
         "v":2,
         "flip":0
      },{
         "type":101,
         "x":9581,
         "y":469,
         "v":3,
         "flip":0
      },{
         "type":101,
         "x":10916,
         "y":451,
         "v":4,
         "flip":0
      }];
      
      private var _twisterLayoutIndex:int = 0;
      
      private var _facts:Array = [{
         "image":"s1",
         "text":11992
      },{
         "image":"s1",
         "text":11993
      },{
         "image":"s2",
         "text":11994
      },{
         "image":"s2",
         "text":11995
      },{
         "image":"s3",
         "text":11996
      },{
         "image":"s3",
         "text":11997
      },{
         "image":"s4",
         "text":11998
      },{
         "image":"s4",
         "text":11999
      },{
         "image":"s5",
         "text":12000
      },{
         "image":"s5",
         "text":12001
      },{
         "image":"s5",
         "text":12002
      },{
         "image":"t6",
         "text":12003
      },{
         "image":"t4",
         "text":12004
      },{
         "image":"t2",
         "text":12005
      },{
         "image":"t3",
         "text":12006
      },{
         "image":"t5",
         "text":12007
      },{
         "image":"t1",
         "text":12008
      },{
         "image":"t10",
         "text":12009
      }];
      
      private var _audio:Array = ["twister_light_wind.mp3","Twister_tornado.mp3","twister_collision_bird.mp3","twister_passby_earth.mp3","twister_passby_Large_wood.mp3","twister_passby_small_wood.mp3","twister_passby_tree.mp3","twister_passby_whoosh_small.mp3","twister_ring.mp3","twister_phantom_passby.mp3","twister_passby_small1.mp3","twister_passby_small2.mp3","twister_passby_glass.mp3","twister_stinger_success.mp3","twister_stinger_fail.mp3","twister_count_down.mp3"];
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerScrollingBackground:Sprite;
      
      public var _layerScrollingForeground:Sprite;
      
      public var _layerScrollingGui:Sprite;
      
      public var _layerObstacles:Sprite;
      
      public var _layerRings:Sprite;
      
      public var _layerTornado:Sprite;
      
      public var _layerPlayer:Sprite;
      
      public var _layerScrollingBackgroundXPos:Number;
      
      public var _obstacleMask:Sprite;
      
      public var _ringMask:Sprite;
      
      public var _clouds:Array;
      
      public var _cloudIndex:int;
      
      public var _cloudDistance:Number;
      
      public var _obstacles:Array;
      
      public var _obstaclesIndex:Array;
      
      public var _bgElements:Array;
      
      public var _bgElementsIndex:Array;
      
      public var _rings:Array;
      
      public var _ringIndex:int;
      
      public var _starTrails:Array;
      
      public var _starTrailIndex:int;
      
      public var _score:Number;
      
      public var _lastPlayerPosX:Number;
      
      public var _currentLayoutXOffset:Number;
      
      public var _obstacleType:Dictionary;
      
      public var _obstacleTimer:Dictionary;
      
      public var _sndTransformTemp:SoundTransform;
      
      public var _playerXDif:Number;
      
      public var _small_whoosh_index:int;
      
      public var _highScore:Number;
      
      public var _gameSuccesTimer:Number;
      
      public var _displayAchievementTimer:Number;
      
      public var _ringsCollected:int;
      
      public var _gemPayoutLookup:Dictionary;
      
      public var _tempAccumulator:int = 0;
      
      public var _player1:TwisterPlayer;
      
      public var _soundMan:SoundManager;
      
      public var _gameState:int;
      
      public var _level:int;
      
      private var _soundNameLightWind:String = _audio[0];
      
      private var _soundNameTornado:String = _audio[1];
      
      internal var _soundNameCollisionBird:String = _audio[2];
      
      private var _soundNamePassbyEarth:String = _audio[3];
      
      private var _soundNamePassbyLargeWood:String = _audio[4];
      
      private var _soundNamePassbySmallWood:String = _audio[5];
      
      private var _soundNamePassbyTree:String = _audio[6];
      
      private var _soundNamePassbyWhooshSmall0:String = _audio[7];
      
      private var _soundNameRing:String = _audio[8];
      
      private var _soundNamePhantomPassby:String = _audio[9];
      
      private var _soundNamePassbyWhooshSmall1:String = _audio[10];
      
      private var _soundNamePassbyWhooshSmall2:String = _audio[11];
      
      private var _soundNamePassbyGlass:String = _audio[12];
      
      private var _soundNameStingerSuccess:String = _audio[13];
      
      internal var _soundNameStingerFail:String = _audio[14];
      
      private var _soundNameCountDown:String = _audio[15];
      
      public var _SFX_Twister_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var _SFX_Twister_tornado:SoundChannel;
      
      private var _SFX_twister_light_wind:SoundChannel;
      
      public function Twister()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Twister_Music = _soundMan.addStream("AJ_mus_twister",1);
         _soundMan.addSoundByName(_audioByName[_soundNameLightWind],_soundNameLightWind,1);
         _soundMan.addSoundByName(_audioByName[_soundNameTornado],_soundNameTornado,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCollisionBird],_soundNameCollisionBird,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyEarth],_soundNamePassbyEarth,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyLargeWood],_soundNamePassbyLargeWood,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbySmallWood],_soundNamePassbySmallWood,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyTree],_soundNamePassbyTree,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyWhooshSmall0],_soundNamePassbyWhooshSmall0,1);
         _soundMan.addSoundByName(_audioByName[_soundNameRing],_soundNameRing,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomPassby],_soundNamePhantomPassby,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyWhooshSmall1],_soundNamePassbyWhooshSmall1,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyWhooshSmall2],_soundNamePassbyWhooshSmall2,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePassbyGlass],_soundNamePassbyGlass,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerSuccess],_soundNameStingerSuccess,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown],_soundNameCountDown,0.8);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function stopBGSounds() : void
      {
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_SFX_twister_light_wind)
         {
            _SFX_twister_light_wind.stop();
            _SFX_twister_light_wind = null;
         }
         if(_SFX_Twister_tornado)
         {
            _SFX_Twister_tornado.stop();
            _SFX_Twister_tornado = null;
         }
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         releaseBase();
         stopBGSounds();
         stage.removeEventListener("keyDown",gameComplete2KeyDown);
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("keyDown",gameOver2KeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("click",mouseClickHandler);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerScrollingBackground);
         removeLayer(_layerPlayer);
         removeLayer(_layerScrollingForeground);
         removeLayer(_layerObstacles);
         removeLayer(_layerRings);
         removeLayer(_layerTornado);
         removeLayer(_layerScrollingGui);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerScrollingBackground = null;
         _layerPlayer = null;
         _layerScrollingForeground = null;
         _layerObstacles = null;
         _layerRings = null;
         _layerTornado = null;
         _layerScrollingGui = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         var _loc1_:int = 0;
         _ringsCollected = 0;
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            setGameState(0);
            _gemPayoutLookup = new Dictionary();
            _gemPayoutLookup[3000] = 1;
            _gemPayoutLookup[4000] = 2;
            _gemPayoutLookup[5000] = 3;
            _gemPayoutLookup[6000] = 4;
            _gemPayoutLookup[7000] = 5;
            _gemPayoutLookup[8000] = 6;
            _gemPayoutLookup[9000] = 7;
            _gemPayoutLookup[10000] = 8;
            _gemPayoutLookup[11000] = 10;
            _gemPayoutLookup[12000] = 12;
            _gemPayoutLookup[13000] = 14;
            _gemPayoutLookup[14000] = 16;
            _gemPayoutLookup[15000] = 18;
            _gemPayoutLookup[16000] = 20;
            _gemPayoutLookup[17000] = 22;
            _gemPayoutLookup[18000] = 24;
            _gemPayoutLookup[19000] = 26;
            _gemPayoutLookup[20000] = 28;
            _gemPayoutLookup[21000] = 30;
            _gemPayoutLookup[22000] = 32;
            _gemPayoutLookup[23000] = 34;
            _gemPayoutLookup[24000] = 36;
            _gemPayoutLookup[25000] = 38;
            _gemPayoutLookup[26000] = 40;
            _gemPayoutLookup[27000] = 45;
            _gemPayoutLookup[28000] = 50;
            _gemPayoutLookup[29000] = 55;
            _gemPayoutLookup[30000] = 60;
            _gemPayoutLookup[31000] = 70;
            _gemPayoutLookup[32000] = 80;
            _gemPayoutLookup[33000] = 90;
            _gemPayoutLookup[34000] = 100;
            _gemPayoutLookup[35000] = 125;
            _layerBackground = new Sprite();
            _layerScrollingBackground = new Sprite();
            _layerPlayer = new Sprite();
            _layerScrollingForeground = new Sprite();
            _layerObstacles = new Sprite();
            _layerRings = new Sprite();
            _layerTornado = new Sprite();
            _layerScrollingGui = new Sprite();
            _guiLayer = new Sprite();
            _obstacleMask = new Sprite();
            _ringMask = new Sprite();
            _obstacleTimer = new Dictionary();
            _obstacleType = new Dictionary();
            _small_whoosh_index = 0;
            _highScore = 0;
            _gameSuccesTimer = 0;
            _twisterLayout.sortOn("x",16);
            _loc1_ = _twisterLayout.length - 1;
            while(_loc1_ > 0)
            {
               _twisterLayout[_loc1_].x -= _twisterLayout[_loc1_ - 1].x;
               _loc1_--;
            }
            _twisterLayout[0].x = Math.round(180 * 5);
            _currentLayoutXOffset = 0;
            addChild(_layerBackground);
            addChild(_layerScrollingBackground);
            addChild(_layerRings);
            addChild(_layerPlayer);
            addChild(_layerScrollingForeground);
            addChild(_layerObstacles);
            addChild(_layerTornado);
            addChild(_layerScrollingGui);
            addChild(_guiLayer);
            loadScene("TwisterAssets/game_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_Twister_Music,0,999999);
         _obstacleMask.graphics.beginFill(16711680);
         _obstacleMask.graphics.drawRect(0,0,900,550);
         addChild(_obstacleMask);
         _ringMask.graphics.beginFill(16711680);
         _ringMask.graphics.drawRect(0,0,900,550);
         addChild(_ringMask);
         _scene.getLayer("frame").loader.content.twister_record.text = "0";
         _layerBackground.addChild(_scene.getLayer("background1").loader);
         _guiLayer.addChild(_scene.getLayer("frame").loader);
         _layerObstacles.mask = _obstacleMask;
         _layerRings.mask = _ringMask;
         _layerTornado.addChild(_scene.getLayer("tornado").loader);
         _layerTornado.addChild(_scene.getLayer("playerGlow").loader);
         _layerScrollingGui.addChild(_scene.getLayer("bonus").loader);
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _clouds = [];
         _cloudIndex = 0;
         _clouds.push(_scene.getLayer("bg1").loader);
         _clouds.push(_scene.cloneAsset("bg1").loader);
         _clouds.push(_scene.cloneAsset("bg1").loader);
         _cloudDistance = 0;
         _clouds[0].x = 900;
         _clouds[0].y = 200;
         _layerScrollingBackground.addChild(_clouds[_cloudIndex++]);
         _obstacles = [];
         _obstaclesIndex = new Array(15);
         _bgElements = [];
         _bgElementsIndex = new Array(3);
         _rings = [];
         _ringIndex = 0;
         _starTrails = [];
         _starTrailIndex = 0;
         _loc3_ = 0;
         while(_loc3_ < 5)
         {
            _loc5_ = {};
            _loc5_.loader = _scene.getLayer("ring" + _loc3_).loader;
            _rings.push(_loc5_);
            _loc3_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 15)
         {
            _loc5_ = {};
            _loc5_.loader = _scene.getLayer("obstacle" + (_loc4_ + 1)).loader;
            _obstacles.push(_loc5_);
            _obstaclesIndex[_loc4_] = 0;
            _loc5_.regSet = false;
            _loc3_ = 0;
            while(_loc3_ < 5 - 1)
            {
               _loc5_ = {};
               _loc5_.loader = _scene.cloneAsset("obstacle" + (_loc4_ + 1)).loader;
               _obstacles.push(_loc5_);
               _loc5_.regSet = false;
               _loc3_++;
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 3)
         {
            _loc5_ = {};
            _loc5_.loader = _scene.getLayer("bg" + (_loc4_ + 2)).loader;
            _bgElements.push(_loc5_);
            _bgElementsIndex[_loc4_] = 0;
            _loc3_ = 0;
            while(_loc3_ < 5 - 1)
            {
               _loc5_ = {};
               _loc5_.loader = _scene.cloneAsset("bg" + (_loc4_ + 2)).loader;
               _bgElements.push(_loc5_);
               _loc3_++;
            }
            _loc4_++;
         }
         _starTrails.push(_scene.getLayer("starTrail"));
         _loc3_ = 0;
         while(_loc3_ < 20 - 1)
         {
            _loc5_ = {};
            _loc5_.loader = _scene.cloneAsset("starTrail").loader;
            _starTrails.push(_loc5_);
            _loc3_++;
         }
         _SFX_twister_light_wind = _soundMan.playByName(_soundNameLightWind,100,100000);
         _SFX_Twister_tornado = _soundMan.playByName(_soundNameTornado,100,100000);
         updatePositionalSound(0,0);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("click",mouseClickHandler);
         super.sceneLoaded(param1);
         startGame();
         _player1._glowLoader = _scene.getLayer("playerGlow").loader;
         _player1._glowLoader.scaleX = 0.6;
         _player1._glowLoader.scaleY = 0.6;
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
            if(showGemMultiplierDlg(onGemMultiplierDone) == null)
            {
               end(param1);
            }
            return;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc12_:Object = null;
         var _loc3_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc16_:Point = null;
         var _loc9_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc10_:Object = null;
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
            if(!_pauseGame && _gameState == 2)
            {
               incrementScore(100 * _frameTime);
               _scene.getLayer("frame").loader.content.twister_score.text = String(Math.floor(_score));
               _gameTime += _frameTime;
               _loc6_ = 0;
               while(_loc6_ < _layerObstacles.numChildren)
               {
                  _loc12_ = _layerObstacles.getChildAt(_loc6_);
                  _loc3_ = false;
                  _loc15_ = Boolean(_loc12_.content.hasOwnProperty("collision0"));
                  _loc8_ = 0;
                  while(_loc8_ < 5)
                  {
                     _loc7_ = false;
                     if(_loc8_ == 0 && !_loc15_)
                     {
                        _loc7_ = true;
                        _loc16_ = new Point(0,0);
                        _loc9_ = Number(_loc12_.width);
                        _loc17_ = Number(_loc12_.height);
                     }
                     else if(_loc12_.content.hasOwnProperty("collision" + _loc8_))
                     {
                        _loc7_ = true;
                        _loc16_ = getWorldCoords(_loc12_.content["collision" + _loc8_]);
                        _loc9_ = Number(_loc12_.content["collision" + _loc8_].width);
                        _loc17_ = Number(_loc12_.content["collision" + _loc8_].height);
                     }
                     if(_loc7_)
                     {
                        if(boxCollisionTest(_player1._clone.loader.x + _player1._clone.loader.content.collision.x,_player1._clone.loader.y + _player1._clone.loader.content.collision.y,_player1._clone.loader.content.collision.width,_player1._clone.loader.content.collision.height,_loc16_.x,_loc16_.y,_loc9_,_loc17_))
                        {
                           _player1.setColliding(true);
                           _loc3_ = true;
                           break;
                        }
                     }
                     _loc8_++;
                  }
                  if(_loc3_)
                  {
                     break;
                  }
                  _loc6_++;
               }
               if(_loc3_ == false)
               {
                  _player1.setColliding(false);
               }
               _loc6_ = 0;
               while(_loc6_ < _layerRings.numChildren)
               {
                  _loc12_ = _layerRings.getChildAt(_loc6_);
                  if(boxCollisionTest(_player1._clone.loader.x + _player1._clone.loader.content.collision.x,_player1._clone.loader.y + _player1._clone.loader.content.collision.y,_player1._clone.loader.content.collision.width,_player1._clone.loader.content.collision.height,_loc12_.x + _loc12_.content.collision.x + _layerRings.x,_loc12_.y + _loc12_.content.collision.y,_loc12_.content.collision.width,_loc12_.content.collision.height))
                  {
                     if(_layerScrollingForeground.numChildren == 0)
                     {
                        _layerScrollingForeground.addChild(_scene.getLayer("ringFront").loader);
                     }
                     if(_loc12_.content.ringCollected == false)
                     {
                        _loc10_ = _scene.getLayer("bonus").loader;
                        _loc10_.x = _loc12_.x;
                        _loc10_.y = _loc12_.y;
                        _loc10_.content.giveBonus(1000);
                        _soundMan.playByName(_soundNameRing);
                        _ringsCollected++;
                        if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                        {
                           AchievementXtCommManager.requestSetUserVar(81,_ringsCollected);
                           _displayAchievementTimer = 1;
                        }
                        if(_layerScrollingGui.numChildren == 0)
                        {
                           _layerScrollingGui.addChild(_scene.getLayer("bonus").loader);
                        }
                        _scene.getLayer("ringFront").loader.x = _loc12_.x;
                        _scene.getLayer("ringFront").loader.y = _loc12_.y;
                        _scene.getLayer("ringFront").loader.content.reset();
                        _scene.getLayer("ringFront").loader.content.collect();
                        _loc12_.content.collect();
                        incrementScore(1000);
                     }
                     break;
                  }
                  _loc6_++;
               }
               for(_loc12_ in _obstacleTimer)
               {
                  if(_obstacleTimer[_loc12_] > 0)
                  {
                     var _loc18_:* = _loc12_;
                     var _loc19_:* = _obstacleTimer[_loc18_] - _frameTime;
                     _obstacleTimer[_loc18_] = _loc19_;
                  }
               }
               _loc6_ = 0;
               while(_loc6_ < _layerObstacles.numChildren)
               {
                  _loc12_ = _layerObstacles.getChildAt(_loc6_);
                  _loc14_ = _loc12_.x + _loc12_.parent.x - _player1._clone.loader.x;
                  if((_obstacleTimer[_loc12_] == null || _obstacleTimer[_loc12_] <= 0) && _loc14_ < 200 && _loc14_ > 0)
                  {
                     switch(_obstacleType[_loc12_])
                     {
                        case 1:
                        case 2:
                        case 8:
                        case 14:
                           _soundMan.playByName(_soundNamePassbyLargeWood);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                        case 3:
                           _soundMan.playByName(_soundNamePassbyEarth);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                        case 6:
                           _soundMan.playByName(_soundNamePhantomPassby);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                        case 7:
                           _soundMan.playByName(_soundNamePassbyGlass);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                        case 4:
                        case 5:
                        case 9:
                        case 13:
                        case 15:
                           if(_small_whoosh_index == 0)
                           {
                              _soundMan.playByName(_soundNamePassbyWhooshSmall0);
                           }
                           else if(_small_whoosh_index == 1)
                           {
                              _soundMan.playByName(_soundNamePassbyWhooshSmall1);
                           }
                           else
                           {
                              _soundMan.playByName(_soundNamePassbyWhooshSmall2);
                           }
                           _small_whoosh_index++;
                           break;
                        case 10:
                           _soundMan.playByName(_soundNamePassbyTree);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                        case 11:
                        case 12:
                           _soundMan.playByName(_soundNamePassbySmallWood);
                           _obstacleTimer[_loc12_] = 2;
                           break;
                     }
                     if(_small_whoosh_index >= 3)
                     {
                        _small_whoosh_index = 0;
                     }
                     _obstacleTimer[_loc12_] = 2;
                  }
                  _loc6_++;
               }
               _loc6_ = 0;
               while(_loc6_ < _layerRings.numChildren)
               {
                  _loc12_ = _layerRings.getChildAt(_loc6_);
                  _loc6_++;
               }
               if(_gameSuccesTimer > 0)
               {
                  _gameSuccesTimer -= _frameTime;
                  if(_gameSuccesTimer <= 0)
                  {
                     _gameSuccesTimer = 0;
                     _gameState = 4;
                     _soundMan.playByName(_soundNameStingerSuccess);
                     stopBGSounds();
                  }
                  if(_gameSuccesTimer <= 1.5)
                  {
                     _scene.getLayer("tornado").loader.alpha = _gameSuccesTimer / 1.5;
                  }
               }
               _player1.heartbeat(_frameTime);
               moveBackground();
               updateLayout();
               _loc4_ = _player1._clone.loader.x - getTornadoX();
               _loc5_ = Math.max(0,(_loc4_ - 100) / 400);
               _loc5_ = Math.min(1,_loc5_);
               updatePositionalSound(1 - _loc5_,_loc5_);
               shakeScreen(Math.max(0,-0.028 * _loc4_ + 10));
            }
            else if(_gameState == 3)
            {
               if(!_pauseGame)
               {
                  showGameOverDlg();
               }
            }
            else if(_gameState == 4)
            {
               if(_score > _highScore)
               {
                  _highScore = _score;
                  _scene.getLayer("frame").loader.content.twister_record.text = String(Math.floor(_score));
               }
               if(!_pauseGame)
               {
                  showGameCompleteDlg();
               }
            }
            else if(_gameState == 5)
            {
               if(_score > _highScore)
               {
                  _highScore = _score;
                  _scene.getLayer("frame").loader.content.twister_record.text = String(Math.floor(_score));
               }
               _layerPlayer.visible = false;
               _player1._glowLoader.visible = false;
               setTornadoX(getTornadoX() + 500 * _frameTime);
               if(getTornadoX() > 1000)
               {
                  _gameState = 3;
               }
            }
         }
      }
      
      public function addStarTrail() : void
      {
         var _loc1_:Object = _starTrails[_starTrailIndex].loader;
         _layerScrollingBackground.addChild(_loc1_ as DisplayObject);
         _loc1_.x = _player1._clone.loader.x - _layerScrollingBackground.x;
         _loc1_.y = _player1._clone.loader.y;
         if(_loc1_.content)
         {
            _loc1_.content.reset();
         }
         _starTrailIndex++;
         if(_starTrailIndex == 20)
         {
            _starTrailIndex = 0;
         }
      }
      
      private function updatePositionalSound(param1:Number, param2:Number) : void
      {
         if(_SFX_twister_light_wind && !SBAudio.isMusicMuted)
         {
            _sndTransformTemp = _SFX_twister_light_wind.soundTransform;
            _sndTransformTemp.volume = param2;
            _SFX_twister_light_wind.soundTransform = _sndTransformTemp;
            _sndTransformTemp = _SFX_Twister_tornado.soundTransform;
            _sndTransformTemp.volume = param1;
            _sndTransformTemp.pan = -1 + param1 * 0.5;
            _SFX_Twister_tornado.soundTransform = _sndTransformTemp;
         }
      }
      
      private function updateLayout() : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         for each(_loc3_ in _obstacles)
         {
            if(_loc3_.v && _loc3_.v != 0)
            {
               _loc3_.loader.x += _frameTime * _loc3_.v * 40;
            }
            if(_loc3_.loader.content)
            {
               if(_loc3_.regSet == false)
               {
                  setRegPoint(_loc3_.loader,_loc3_.loader.width / 2,_loc3_.loader.height / 2);
                  _loc3_.regSet = true;
               }
               if(_loc3_.rotationRate && _loc3_.rotationRate != 0)
               {
                  _loc3_.loader.rotation += _frameTime * _loc3_.rotationRate;
               }
            }
         }
         for each(_loc3_ in _bgElements)
         {
            if(_loc3_.v && _loc3_.v != 0)
            {
               _loc3_.loader.x += _frameTime * _loc3_.v * 40 * (_playerXDif / _frameTime / 180);
            }
         }
         for each(_loc3_ in _rings)
         {
            if(_loc3_.v && _loc3_.v != 0)
            {
               _loc3_.loader.x += _frameTime * _loc3_.v * 40;
            }
         }
         _loc3_ = _twisterLayout[_twisterLayoutIndex];
         while(_currentLayoutXOffset > _loc3_.x)
         {
            if(_loc3_.type == 0)
            {
               _rings[_ringIndex].loader.x = 900 - _layerRings.x;
               _rings[_ringIndex].loader.y = _loc3_.y;
               _rings[_ringIndex].v = _loc3_.v;
               _rings[_ringIndex].loader.content.reset();
               _layerRings.addChild(_rings[_ringIndex++].loader);
               if(_ringIndex == _rings.length)
               {
                  _ringIndex = 0;
               }
            }
            else if(_loc3_.type < 100)
            {
               _loc2_ = (_loc3_.type - 1) * 5 + _obstaclesIndex[_loc3_.type - 1];
               _obstacles[_loc2_].v = _loc3_.v;
               _obstacles[_loc2_].rotationRate = _loc3_.rotationRate;
               _obstaclesIndex[_loc3_.type - 1] < 5 - 1 ? _obstaclesIndex[_loc3_.type - 1]++ : (_obstaclesIndex[_loc3_.type - 1] = 0);
               _loc1_ = _layerObstacles.addChild(_obstacles[_loc2_].loader);
               _loc1_.x = 900 - _layerObstacles.x;
               _loc1_.y = _loc3_.y;
               _obstacles[_loc2_].loader.rotation = 0;
               _obstacleType[_loc1_] = _loc3_.type;
               if(_obstacles[_loc2_].regSet)
               {
                  _loc1_.x += _obstacles[_loc2_].loader.width / 2;
                  _loc1_.y += _obstacles[_loc2_].loader.height / 2;
               }
               if(_loc3_.flip != 0)
               {
                  _loc1_.scaleX = -1;
               }
               else
               {
                  _loc1_.scaleX = 1;
               }
            }
            else
            {
               _loc2_ = (_loc3_.type - 101) * 5 + _bgElementsIndex[_loc3_.type - 101];
               _bgElements[_loc2_].v = _loc3_.v;
               _bgElementsIndex[_loc3_.type - 101] < 5 - 1 ? _bgElementsIndex[_loc3_.type - 101]++ : (_bgElementsIndex[_loc3_.type - 101] = 0);
               _loc1_ = _layerScrollingBackground.addChild(_bgElements[_loc2_].loader);
               _loc1_.x = 900 - _layerScrollingBackground.x;
               _loc1_.y = _loc3_.y;
               if(_loc3_.flip != 0)
               {
                  _loc1_.scaleZ = -1;
                  _loc1_.rotation = 180;
                  _loc1_.rotationX = 180;
                  _loc1_.rotationZ = 180;
                  _loc1_.x += _loc1_.width;
               }
               else
               {
                  _loc1_.scaleZ = 1;
                  _loc1_.rotation = 0;
                  _loc1_.rotationX = 0;
                  _loc1_.rotationZ = 0;
               }
            }
            _currentLayoutXOffset -= _loc3_.x;
            _twisterLayoutIndex++;
            if(_twisterLayoutIndex == _twisterLayout.length)
            {
               _twisterLayoutIndex = 0;
               _gameSuccesTimer = 6;
            }
            _loc3_ = _twisterLayout[_twisterLayoutIndex];
         }
      }
      
      private function getWorldCoords(param1:Object) : Point
      {
         var _loc3_:Number = Number(param1.x);
         var _loc2_:Number = Number(param1.y);
         var _loc4_:* = param1;
         while(_loc4_.parent)
         {
            _loc4_ = _loc4_.parent;
            _loc3_ += _loc4_.x;
            _loc2_ += _loc4_.y;
         }
         return new Point(_loc3_,_loc2_);
      }
      
      private function setRegPoint(param1:DisplayObjectContainer, param2:Number, param3:Number) : void
      {
         var _loc8_:int = 0;
         var _loc6_:Rectangle = param1.getBounds(param1.parent);
         var _loc5_:Number = param2 - 0;
         var _loc4_:Number = param3 - 0;
         param1.x += _loc5_;
         param1.y += _loc4_;
         _loc8_ = 0;
         while(_loc8_ < param1.numChildren)
         {
            param1.getChildAt(_loc8_).x = param1.getChildAt(_loc8_).x - _loc5_;
            param1.getChildAt(_loc8_).y = param1.getChildAt(_loc8_).y - _loc4_;
            _loc8_++;
         }
      }
      
      private function unsetRegPoint(param1:DisplayObjectContainer, param2:Number, param3:Number) : void
      {
         var _loc8_:int = 0;
         var _loc6_:Rectangle = param1.getBounds(param1.parent);
         var _loc5_:Number = param2 - 0;
         var _loc4_:Number = param3 - 0;
         param1.x -= _loc5_;
         param1.y -= _loc4_;
         _loc8_ = 0;
         while(_loc8_ < param1.numChildren)
         {
            param1.getChildAt(_loc8_).x = param1.getChildAt(_loc8_).x + _loc5_;
            param1.getChildAt(_loc8_).y = param1.getChildAt(_loc8_).y + _loc4_;
            _loc8_++;
         }
      }
      
      private function updateTornado() : void
      {
         var _loc1_:Number = _player1.getXSpeed() / 150;
         var _loc2_:Number = 10 * (1 - _player1.getXSpeed() / (150 * 0.75));
         if(_loc2_ >= 0 || _scene.getLayer("tornado").loader.x > -150)
         {
            _scene.getLayer("tornado").loader.x = _scene.getLayer("tornado").loader.x + _loc2_ * _frameTime;
         }
      }
      
      public function getTornadoX() : Number
      {
         return _scene.getLayer("tornado").loader.x;
      }
      
      public function setTornadoX(param1:Number) : void
      {
         _scene.getLayer("tornado").loader.x = param1;
         if(param1 >= -30)
         {
            _obstacleMask.x = param1 + 30;
            _ringMask.x = param1 + 30;
         }
      }
      
      public function doCountdown() : void
      {
         _guiLayer.addChild(_scene.getLayer("countdown").loader);
         _scene.getLayer("countdown").loader.content.counter.gotoAndPlay("on");
         _scene.getLayer("countdown").loader.x = 300;
         _scene.getLayer("countdown").loader.y = 100;
         _soundMan.playByName(_soundNameCountDown);
      }
      
      private function moveBackground() : void
      {
         var _loc1_:int = 0;
         var _loc3_:Loader = null;
         _playerXDif = _player1._bird_posX - _lastPlayerPosX;
         _currentLayoutXOffset += _playerXDif;
         _layerScrollingBackgroundXPos = -_player1._bird_posX;
         _layerScrollingBackground.x = Math.floor(_layerScrollingBackgroundXPos);
         _layerObstacles.x = _layerScrollingForeground.x = _layerRings.x = _layerScrollingGui.x = _layerScrollingBackground.x;
         _cloudDistance += _playerXDif;
         _lastPlayerPosX = _player1._bird_posX;
         if(_cloudDistance > 400)
         {
            _clouds[_cloudIndex].x = 900 - _layerScrollingBackground.x;
            _clouds[_cloudIndex].y = Math.floor(Math.random() * 300);
            _layerScrollingBackground.addChild(_clouds[_cloudIndex++]);
            if(_cloudIndex == _clouds.length)
            {
               _cloudIndex = 0;
            }
            _cloudDistance = 0;
         }
         if(_layerScrollingBackground.x < -900)
         {
            _layerScrollingBackground.x += 900;
            _layerObstacles.x += 900;
            _layerScrollingForeground.x += 900;
            _layerScrollingGui.x += 900;
            _layerRings.x += 900;
            _layerScrollingBackgroundXPos += 900;
            _player1._bird_posX -= 900;
            _player1._tornadoPosX -= 900;
            _lastPlayerPosX -= 900;
            _loc1_ = 0;
            while(_loc1_ < _layerScrollingBackground.numChildren)
            {
               if(_layerScrollingBackground.getChildAt(_loc1_).width != 900)
               {
                  _layerScrollingBackground.getChildAt(_loc1_).x = _layerScrollingBackground.getChildAt(_loc1_).x - 900;
               }
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _layerObstacles.numChildren)
            {
               _layerObstacles.getChildAt(_loc1_).x = _layerObstacles.getChildAt(_loc1_).x - 900;
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _layerScrollingForeground.numChildren)
            {
               _layerScrollingForeground.getChildAt(_loc1_).x = _layerScrollingForeground.getChildAt(_loc1_).x - 900;
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _layerScrollingGui.numChildren)
            {
               _layerScrollingGui.getChildAt(_loc1_).x = _layerScrollingGui.getChildAt(_loc1_).x - 900;
               _loc1_++;
            }
            _loc1_ = 0;
            while(_loc1_ < _layerRings.numChildren)
            {
               _layerRings.getChildAt(_loc1_).x = _layerRings.getChildAt(_loc1_).x - 900;
               _loc1_++;
            }
         }
         _loc1_ = _layerScrollingBackground.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = Loader(_layerScrollingBackground.getChildAt(_loc1_));
            if(_loc3_.content && _loc3_.width != 900 && _loc3_.x + _layerScrollingBackground.x < -_loc3_.width - 450)
            {
               _layerScrollingBackground.removeChildAt(_loc1_);
            }
            _loc1_--;
         }
         _loc1_ = _layerObstacles.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = Loader(_layerObstacles.getChildAt(_loc1_));
            if(_loc3_.content && _loc3_.x + _layerObstacles.x < -_loc3_.width - 450)
            {
               _layerObstacles.removeChildAt(_loc1_);
            }
            _loc1_--;
         }
         _loc1_ = _layerScrollingForeground.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = Loader(_layerScrollingForeground.getChildAt(_loc1_));
            if(_loc3_.content && _loc3_.x + _layerScrollingForeground.x < -_loc3_.width - 450)
            {
               _layerScrollingForeground.removeChildAt(_loc1_);
            }
            _loc1_--;
         }
         _loc1_ = _layerScrollingGui.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = Loader(_layerScrollingGui.getChildAt(_loc1_));
            if(_loc3_.content && _loc3_.x + _layerScrollingGui.x < -_loc3_.width - 450)
            {
               _layerScrollingGui.removeChildAt(_loc1_);
            }
            _loc1_--;
         }
         _loc1_ = _layerRings.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = Loader(_layerRings.getChildAt(_loc1_));
            if(_loc3_.content && _loc3_.x + _layerRings.x < -_loc3_.width - 450)
            {
               _layerRings.removeChildAt(_loc1_);
            }
            _loc1_--;
         }
      }
      
      private function boxCollisionTest(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         var _loc13_:* = NaN;
         var _loc11_:* = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc12_:* = NaN;
         var _loc14_:* = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Number = NaN;
         _loc13_ = param1;
         _loc11_ = param5;
         _loc15_ = param1 + param3;
         _loc16_ = param5 + param7;
         _loc12_ = param2;
         _loc14_ = param6;
         _loc10_ = param2 + param4;
         _loc9_ = param6 + param8;
         if(_loc10_ < _loc14_)
         {
            return false;
         }
         if(_loc12_ > _loc9_)
         {
            return false;
         }
         if(_loc15_ < _loc11_)
         {
            return false;
         }
         if(_loc13_ > _loc16_)
         {
            return false;
         }
         return true;
      }
      
      public function startGame() : void
      {
         _layerBackground.x = 0;
         _layerBackground.y = 0;
         _layerScrollingBackgroundXPos = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _player1 = new TwisterPlayer(this);
         _lastPlayerPosX = _player1._clone.loader.x;
         setGameState(2);
      }
      
      public function resetGame() : void
      {
         var _loc2_:Loader = null;
         var _loc1_:int = 0;
         _layerBackground.x = 0;
         _layerBackground.y = 0;
         _layerScrollingBackgroundXPos = 0;
         _layerPlayer.visible = true;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _twisterLayoutIndex = 0;
         setTornadoX(0);
         _scene.getLayer("tornado").loader.alpha = 1;
         _gameSuccesTimer = 0;
         _ringsCollected = 0;
         _player1.reset();
         _musicLoop = _soundMan.playStream(_SFX_Twister_Music,0,999999);
         _SFX_twister_light_wind = _soundMan.playByName(_soundNameLightWind,100,100000);
         _SFX_Twister_tornado = _soundMan.playByName(_soundNameTornado,100,100000);
         _lastPlayerPosX = _player1._clone.loader.x;
         _currentLayoutXOffset = 0;
         while(_layerScrollingBackground.numChildren)
         {
            _layerScrollingBackground.removeChildAt(0);
         }
         while(_layerObstacles.numChildren)
         {
            _loc2_ = Loader(_layerObstacles.getChildAt(0));
            _layerObstacles.removeChildAt(0);
         }
         while(_layerScrollingForeground.numChildren)
         {
            _layerScrollingForeground.removeChildAt(0);
         }
         while(_layerScrollingGui.numChildren)
         {
            _layerScrollingGui.removeChildAt(0);
         }
         while(_layerRings.numChildren)
         {
            _layerRings.removeChildAt(0);
         }
         _loc1_ = 0;
         while(_loc1_ < _obstaclesIndex.length)
         {
            _obstaclesIndex[_loc1_] = 0;
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < _bgElementsIndex.length)
         {
            _bgElementsIndex[_loc1_] = 0;
            _loc1_++;
         }
         _ringIndex = 0;
         _cloudIndex = 0;
         _cloudDistance = 0;
         _clouds[0].x = 900;
         _clouds[0].y = 200;
         _layerScrollingBackground.addChild(_clouds[_cloudIndex++]);
         setGameState(2);
      }
      
      private function shakeScreen(param1:Number) : void
      {
         x = (Math.random() - 0.5) * param1;
         y = (Math.random() - 0.5) * param1;
      }
      
      private function incrementScore(param1:Number) : void
      {
         var _loc2_:Number = _score;
         _score += param1;
         if(_loc2_ < 30000 && _score >= 30000)
         {
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,30001);
               _displayAchievementTimer = 1;
            }
         }
      }
      
      private function mouseClickHandler(param1:MouseEvent) : void
      {
         if(!_pauseGame && _gameState == 2)
         {
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_NoReset
         }]);
         if(_loc1_)
         {
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function gameOver2KeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGameOverDlg2();
         }
      }
      
      private function gameComplete2KeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGameCompleteDlg2();
         }
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onExit_No();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function showGameOverDlg() : void
      {
         var _loc2_:int = 0;
         stage.addEventListener("keyDown",gameOver2KeyDown);
         var _loc1_:MovieClip = showDlg("twister_result",[{
            "name":"continue_btn",
            "f":showGameOverDlg2
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.random() * _facts.length;
            _loc1_.score.text = String(Math.floor(_score));
            _scene.getLayer(_facts[_loc2_].image).loader.x = 0;
            _scene.getLayer(_facts[_loc2_].image).loader.y = 0;
            _loc1_.result_pic.addChild(_scene.getLayer(_facts[_loc2_].image).loader);
            LocalizationManager.translateId(_loc1_.result_fact,_facts[_loc2_].text);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameOverDlg2() : void
      {
         var _loc2_:int = 0;
         stage.removeEventListener("keyDown",gameOver2KeyDown);
         hideDlg();
         stage.addEventListener("keyDown",replayKeyDown);
         var _loc1_:MovieClip = showDlg("card_twstr_Game_Over",[{
            "name":"button_yes",
            "f":onExit_No
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            if(_score < 3000)
            {
               _loc2_ = 1;
            }
            else if(_score > 35000)
            {
               _loc2_ = 150;
            }
            else
            {
               _loc2_ = int(_gemPayoutLookup[Math.ceil(_score / 1000) * 1000]);
            }
            addGemsToBalance(_loc2_);
            LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_loc2_.toString());
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameCompleteDlg() : void
      {
         var _loc2_:int = 0;
         stage.addEventListener("keyDown",gameComplete2KeyDown);
         var _loc1_:MovieClip = showDlg("twister_result",[{
            "name":"continue_btn",
            "f":showGameCompleteDlg2
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.random() * _facts.length;
            _loc1_.score.text = String(Math.floor(_score));
            _scene.getLayer(_facts[_loc2_].image).loader.x = 0;
            _scene.getLayer(_facts[_loc2_].image).loader.y = 0;
            _loc1_.result_pic.addChild(_scene.getLayer(_facts[_loc2_].image).loader);
            LocalizationManager.translateId(_loc1_.result_fact,_facts[_loc2_].text);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameCompleteDlg2() : void
      {
         var _loc2_:int = 0;
         stage.removeEventListener("keyDown",gameComplete2KeyDown);
         hideDlg();
         stage.addEventListener("keyDown",replayKeyDown);
         var _loc1_:MovieClip = showDlg("card_twstr_greatjob",[{
            "name":"button_yes",
            "f":onExit_No
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            if(_score < 3000)
            {
               _loc2_ = 1;
            }
            else if(_score > 35000)
            {
               _loc2_ = 150;
            }
            else
            {
               _loc2_ = int(_gemPayoutLookup[Math.ceil(_score / 1000) * 1000]);
            }
            addGemsToBalance(_loc2_);
            LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_loc2_.toString());
            _loc1_.x = 450;
            _loc1_.y = 275;
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
      
      private function onExit_No() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         hideDlg();
         resetGame();
      }
      
      private function onExit_NoReset() : void
      {
         hideDlg();
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
   }
}

