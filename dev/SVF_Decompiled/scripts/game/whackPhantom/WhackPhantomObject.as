package game.whackPhantom
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class WhackPhantomObject
   {
      private static const TURN_OFF_TIMER:Number = -0.5;
      
      public static const PHANTOMTYPE_BLACK:int = 0;
      
      public static const PHANTOMTYPE_GRAY:int = 1;
      
      public static const PHANTOMTYPE_RED:int = 2;
      
      public static const PHANTOMTYPE_RANDOM:int = 3;
      
      public var _hole:MovieClip;
      
      public var _type:int;
      
      private var _activeTimer:Number;
      
      public function WhackPhantomObject(param1:MovieClip)
      {
         super();
         _hole = param1;
         _activeTimer = 0;
      }
      
      public function isActive() : Boolean
      {
         return _activeTimer != 0;
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc2_:Boolean = false;
         if(_activeTimer > 0)
         {
            _activeTimer -= param1;
            if(_activeTimer <= 0)
            {
               _loc2_ = true;
               _activeTimer = -0.5;
               switch(_type)
               {
                  case 0:
                     _hole.gotoAndPlay("blackOff");
                     break;
                  case 1:
                     _hole.gotoAndPlay("grayOff");
                     break;
                  case 2:
                     _hole.gotoAndPlay("redOff");
               }
            }
         }
         else if(_activeTimer < 0)
         {
            _activeTimer += param1;
            if(_activeTimer >= 0)
            {
               _activeTimer = 0;
            }
         }
         return _loc2_;
      }
      
      public function reset() : void
      {
         if(_activeTimer > 0)
         {
            switch(_type)
            {
               case 0:
                  _hole.gotoAndPlay("blackOff");
                  break;
               case 1:
                  _hole.gotoAndPlay("grayOff");
                  break;
               case 2:
                  _hole.gotoAndPlay("redOff");
            }
         }
         _activeTimer = 0;
      }
      
      public function activate(param1:int) : void
      {
         if(param1 == 3)
         {
            _type = Math.random() * 3;
         }
         else
         {
            _type = param1;
         }
         switch(_type)
         {
            case 0:
               _hole.gotoAndPlay("blackOn");
               _activeTimer = 1.5;
               break;
            case 1:
               _hole.gotoAndPlay("grayOn");
               _activeTimer = 1.5;
               break;
            case 2:
               _hole.gotoAndPlay("redOn");
               _activeTimer = 0.75;
         }
      }
      
      public function hit(param1:MouseEvent) : Boolean
      {
         if(_activeTimer > 0 && param1.target == _hole)
         {
            switch(_type)
            {
               case 0:
                  _hole.gotoAndPlay("blackHit");
                  break;
               case 1:
                  _hole.gotoAndPlay("grayHit");
                  break;
               case 2:
                  _hole.gotoAndPlay("redHit");
            }
            _activeTimer = -0.5;
            return true;
         }
         return false;
      }
   }
}

