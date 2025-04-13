package game.candyCatcher
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class CandyCatchObject
   {
      public static const CANDYTYPE_CANDY:int = 0;
      
      public static const CANDYTYPE_TRASH:int = 1;
      
      public static const CANDYTYPE_GOLD:int = 2;
      
      private var MIN_FALL_SPEED:int = 50;
      
      private var MAX_FALL_SPEED:int = 175;
      
      public var _candy:MovieClip;
      
      public var _type:int;
      
      public var _fallSpeed:Number;
      
      public function CandyCatchObject(param1:int, param2:int, param3:int, param4:Sprite)
      {
         var _loc5_:int = 0;
         super();
         _candy = GETDEFINITIONBYNAME("candyCatch_object");
         _type = param1;
         switch(_type - 1)
         {
            case 0:
               _loc5_ = Math.random() * 5 + 1;
               _candy.gotoAndStop("trash" + _loc5_);
               MIN_FALL_SPEED = 350;
               MAX_FALL_SPEED = 500;
               break;
            case 1:
               _candy.gotoAndStop("gold");
               MIN_FALL_SPEED = 300;
               MAX_FALL_SPEED = 500;
               break;
            default:
               _loc5_ = Math.random() * 5 + 1;
               _candy.gotoAndStop("candy" + _loc5_);
               MIN_FALL_SPEED = 200;
               MAX_FALL_SPEED = 500;
         }
         _candy.x = param2 + Math.random() * (param3 - param2);
         _candy.y = -_candy.height;
         _fallSpeed = MIN_FALL_SPEED + Math.random() * (MAX_FALL_SPEED - MIN_FALL_SPEED);
         param4.addChild(_candy);
      }
      
      public function destroy() : void
      {
         if(_candy != null)
         {
            if(_candy.parent != null)
            {
               _candy.parent.removeChild(_candy);
            }
            _candy = null;
         }
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         _candy.rotation += 10 * _fallSpeed / MAX_FALL_SPEED;
         _candy.y += _fallSpeed * param1;
         if(_candy.y >= 550 + _candy.height)
         {
            return true;
         }
         return false;
      }
   }
}

