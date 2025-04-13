package game.dolphinRace
{
   import flash.display.MovieClip;
   
   public class DolphinRaceHurdle
   {
      private static const DOLPHINOBSTACLE_0:String = "o_0";
      
      private static const DOLPHINOBSTACLE_1:String = "o_1";
      
      private static const DOLPHINOBSTACLE_2:String = "o_2";
      
      private static const DOLPHINOBSTACLE_3:String = "o_3";
      
      private static const DOLPHINOBSTACLE_4:String = "o_4";
      
      private static const DOLPHINOBSTACLE_1_2:String = "o_1_2";
      
      private static const DOLPHINOBSTACLE_1_3:String = "o_1_3";
      
      private static const DOLPHINOBSTACLE_2_3:String = "o_2_3";
      
      private static const DOLPHINOBSTACLE_0_1_2:String = "o_0_1_2";
      
      private static const DOLPHINOBSTACLE_2_3_4:String = "o_2_3_4";
      
      private static const DOLPHINRING_1:String = "o1";
      
      private static const DOLPHINRING_2:String = "o2";
      
      public static const DR_HURDLE_TYPE_RING:int = 1;
      
      public static const DR_HURDLE_TYPE_OBSTACLE:int = 2;
      
      public static const DR_OBSTACLE_CLASS_DOUBLE_HIGH:int = 0;
      
      public static const DR_OBSTACLE_CLASS_HIGH:int = 1;
      
      public static const DR_OBSTACLE_CLASS_MIDDLE:int = 2;
      
      public static const DR_OBSTACLE_CLASS_LOW:int = 3;
      
      public static const DR_OBSTACLE_CLASS_DOUBLE_LOW:int = 4;
      
      public static const DR_OBSTACLE_CLASS_HIGH_MIDDLE:int = 5;
      
      public static const DR_OBSTACLE_CLASS_HIGH_LOW:int = 6;
      
      public static const DR_OBSTACLE_CLASS_MIDDLE_LOW:int = 7;
      
      public static const DR_OBSTACLE_CLASS_DOUBLEHIGH_HIGH_MIDDLE:int = 8;
      
      public static const DR_OBSTACLE_CLASS_DOUBLELOW_LOW_MIDDLE:int = 9;
      
      public static const DR_RING_MODIFIER_1:int = 0;
      
      public static const DR_RING_MODIFIER_2:int = 1;
      
      public static const DR_RING_CLASS_DOUBLEHIGH:int = 0;
      
      public static const DR_RING_CLASS_HIGH:int = 1;
      
      public static const DR_RING_CLASS_MIDDLE:int = 2;
      
      public static const DR_RING_CLASS_LOW:int = 3;
      
      public static const DR_RING_CLASS_DOUBLELOW:int = 4;
      
      public var _spawnX:Number;
      
      public var _x:Number;
      
      public var _y:Number;
      
      public var _y2:Number;
      
      public var _width:Number;
      
      public var _height:Number;
      
      public var _height2:Number;
      
      public var _type:int;
      
      public var _class:int;
      
      public var _modifier:int;
      
      private var _lanesHit:Array;
      
      public var _debugmc:MovieClip;
      
      private var _theGame:DolphinRace;
      
      public function DolphinRaceHurdle(param1:DolphinRace, param2:int, param3:int, param4:int, param5:int, param6:MovieClip, param7:MovieClip)
      {
         super();
         _theGame = param1;
         _lanesHit = [false,false,false,false];
         _type = param2;
         _class = param3;
         _modifier = param4;
         _spawnX = param5;
         if(_type == 1)
         {
            _width = 20;
            setHurdle(param7);
            _y = param7.y + param7.collision.y - param7.collision.height / 2;
            _height = param7.collision.height;
            switch(_class)
            {
               case 0:
                  _y -= 144;
                  break;
               case 1:
                  _y -= 54;
                  break;
               case 2:
                  _y += 56;
                  break;
               case 3:
                  _y += 156;
                  break;
               case 4:
                  _y += 246;
            }
         }
         else
         {
            setHurdle(param6);
            _width = param6.collision.width;
            _y = param6.y + param6.collision.y - param6.collision.height / 2;
            _height = param6.collision.height;
            _y2 = param6.y + param6.collision2.y - param6.collision2.height / 2;
            _height2 = param6.collision2.height;
         }
         _x = param5 - _width / 2;
      }
      
      public function getLeftEdgeX() : Number
      {
         switch(_type - 1)
         {
            case 0:
               return _x - _width / 2;
            case 1:
               return _x - _width / 2;
            default:
               return 0;
         }
      }
      
      public function getRightEdgeX() : Number
      {
         switch(_type - 1)
         {
            case 0:
               return _x - _width / 2 + _width;
            case 1:
               return _x - _width / 2 + _width;
            default:
               return 0;
         }
      }
      
      public function testCollision(param1:Number, param2:Number, param3:Number, param4:Number, param5:int, param6:Boolean) : int
      {
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         if(_lanesHit[param5] == false)
         {
            switch(_type - 1)
            {
               case 0:
                  _loc8_ = _x - _width / 2;
                  _loc7_ = _y - _height / 2;
                  if(param1 > _loc8_ && param1 < _loc8_ + _width || param1 + param2 > _loc8_ && param1 + param2 < _loc8_ + _width || param1 < _loc8_ && param1 + param2 > _loc8_ + _width)
                  {
                     if(param3 > _loc7_ && param3 < _loc7_ + _height && (param3 + param4 > _loc7_ && param3 + param4 < _loc7_ + _height))
                     {
                        _lanesHit[param5] = true;
                        if(param6)
                        {
                           _theGame._soundMan.playByName(_theGame._soundNameAJDRRingStinger);
                        }
                        return 1;
                     }
                  }
                  break;
               case 1:
                  _loc8_ = _x - _width / 2;
                  _loc7_ = _y;
                  if(param1 > _loc8_ && param1 < _loc8_ + _width || param1 + param2 > _loc8_ && param1 + param2 < _loc8_ + _width || param1 < _loc8_ && param1 + param2 > _loc8_ + _width)
                  {
                     if(param3 > _loc7_ && param3 < _loc7_ + _height || param3 + param4 > _loc7_ && param3 + param4 < _loc7_ + _height || param3 < _loc7_ && param3 + param4 > _loc7_ + _height)
                     {
                        _lanesHit[param5] = true;
                        if(param6)
                        {
                           playHitSound(1);
                        }
                        return 1;
                     }
                     _loc7_ = _y2;
                     if(param3 > _loc7_ && param3 < _loc7_ + _height2 || param3 + param4 > _loc7_ && param3 + param4 < _loc7_ + _height2 || param3 < _loc7_ && param3 + param4 > _loc7_ + _height2)
                     {
                        _lanesHit[param5] = true;
                        if(param6)
                        {
                           playHitSound(2);
                        }
                        return 2;
                     }
                     break;
                  }
            }
         }
         return 0;
      }
      
      private function playHitSound(param1:int) : void
      {
         switch(_class)
         {
            case 0:
               _theGame._soundMan.playByName(_theGame["_soundNameAJDRImpSeagull" + (Math.floor(Math.random() * 3) + 1)]);
               break;
            case 1:
               _theGame._soundMan.playByName(_theGame["_soundNameAJDRImpSeagull" + (Math.floor(Math.random() * 3) + 1)]);
               break;
            case 2:
               _theGame._soundMan.playByName(_theGame["_soundNameAJDRImpBuoySmall" + (Math.floor(Math.random() * 2) + 1)]);
               break;
            case 3:
               _theGame._soundMan.playByName(_theGame._soundNameAJDRBallChain);
               break;
            case 4:
               _theGame._soundMan.playByName(_theGame._soundNameAJDRRockslide);
               break;
            case 5:
               _theGame._soundMan.playByName(_theGame._soundNameAJDRImpBuoyMed);
               break;
            case 6:
               if(param1 == 1)
               {
                  _theGame._soundMan.playByName(_theGame["_soundNameAJDRImpSeagull" + (Math.floor(Math.random() * 3) + 1)]);
                  break;
               }
               _theGame._soundMan.playByName(_theGame._soundNameAJDRBallChain);
               break;
            case 7:
               if(param1 == 1)
               {
                  _theGame._soundMan.playByName(_theGame._soundNameAJDRBallChain);
                  break;
               }
               _theGame._soundMan.playByName(_theGame["_soundNameAJDRImpBuoySmall" + (Math.floor(Math.random() * 2) + 1)]);
               break;
            case 8:
               _theGame._soundMan.playByName(_theGame._soundNameAJDRImpBuoyLarge);
               break;
            case 9:
               _theGame._soundMan.playByName(_theGame._soundNameAJDRRockslide);
         }
      }
      
      public function setHurdle(param1:MovieClip) : void
      {
         _debugmc = param1;
         loop0:
         switch(_type - 1)
         {
            case 0:
               switch(_modifier)
               {
                  case 0:
                     param1.gotoAndPlay("o1");
                     break loop0;
                  case 1:
                     param1.gotoAndPlay("o2");
               }
               break;
            case 1:
               switch(_class)
               {
                  case 0:
                     param1.gotoAndPlay("o_0");
                     break loop0;
                  case 1:
                     param1.gotoAndPlay("o_1");
                     break loop0;
                  case 2:
                     param1.gotoAndPlay("o_2");
                     break loop0;
                  case 3:
                     param1.gotoAndPlay("o_3");
                     break loop0;
                  case 4:
                     param1.gotoAndPlay("o_4");
                     break loop0;
                  case 5:
                     param1.gotoAndPlay("o_1_2");
                     break loop0;
                  case 6:
                     param1.gotoAndPlay("o_1_3");
                     break loop0;
                  case 7:
                     param1.gotoAndPlay("o_2_3");
                     break loop0;
                  case 8:
                     param1.gotoAndPlay("o_0_1_2");
                     break loop0;
                  case 9:
                     param1.gotoAndPlay("o_2_3_4");
               }
         }
      }
   }
}

