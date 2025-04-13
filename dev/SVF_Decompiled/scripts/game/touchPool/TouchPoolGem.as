package game.touchPool
{
   public class TouchPoolGem
   {
      private static const LIFETIME:int = 8;
      
      public var _clone:Object;
      
      public var _lifeTimer:Number;
      
      public var _collected:Boolean;
      
      private var _theGame:TouchPool;
      
      public function TouchPoolGem(param1:TouchPool)
      {
         super();
         _theGame = param1;
         _clone = GETDEFINITIONBYNAME("tierneyPool_gem");
      }
      
      public function reset() : void
      {
         _lifeTimer = 8;
         _collected = false;
         _clone.visible = true;
      }
      
      public function heartbeat(param1:Number) : void
      {
         _lifeTimer -= param1;
         if(_lifeTimer < 3 && !_collected)
         {
            if(Math.floor(_lifeTimer * 10) % 2 == 0)
            {
               _clone.visible = false;
            }
            else
            {
               _clone.visible = true;
            }
         }
         if(_lifeTimer <= 0)
         {
            if(_clone.parent)
            {
               _clone.parent.removeChild(_clone);
            }
         }
         if(_clone.bounceSound)
         {
            _clone.bounceSound = false;
            _theGame._soundMan.playByName(_theGame["_soundNameGemCollision" + (Math.floor(Math.random() * 3) + 1)]);
         }
      }
      
      public function collect() : void
      {
         _collected = true;
         _clone.collect();
         _clone.visible = true;
         _lifeTimer = 2;
      }
   }
}

