package game.shootingGallery
{
   public class ShootingGalleryObject
   {
      private var _theGame:ShootingGallery;
      
      public var _clone:Object;
      
      public var _type:int;
      
      public var _letter:int;
      
      public var _decisionTime:Number;
      
      public var _isAttacking:Boolean;
      
      public var _speed:Number;
      
      public var _row:int;
      
      public function ShootingGalleryObject(param1:ShootingGallery)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:Object) : void
      {
         _clone = param1;
         getDecisionTime();
      }
      
      public function reset() : void
      {
         getDecisionTime();
         _isAttacking = false;
         _clone.visible = true;
      }
      
      private function getDecisionTime() : void
      {
         _decisionTime = Math.random() < 0.2 ? Math.random() * 7 + 2 : 100;
      }
      
      public function heartbeat(param1:Number) : void
      {
         if(_type == 3)
         {
            if(_isAttacking)
            {
               if(!_clone.target.active)
               {
                  _theGame.stealBullets();
                  _isAttacking = false;
               }
            }
            else if(_clone.target.active)
            {
               updatePos(param1);
               _decisionTime -= param1;
               if(_decisionTime <= 0)
               {
                  if(_theGame._numAttackers < 2 && _clone.x < 875 && _clone.x > 25)
                  {
                     _clone.target.phantomAttack2();
                     _isAttacking = true;
                     _theGame._numAttackers++;
                     _theGame._soundMan.playByName(_theGame["_soundNamePhantomDescends" + (Math.random() > 0.5 ? 1 : 2)]);
                  }
                  else
                  {
                     getDecisionTime();
                  }
               }
            }
         }
         else
         {
            updatePos(param1);
         }
      }
      
      private function updatePos(param1:Number) : void
      {
         _clone.x += _speed * param1;
      }
   }
}

