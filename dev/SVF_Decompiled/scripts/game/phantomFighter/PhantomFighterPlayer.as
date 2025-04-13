package game.phantomFighter
{
   import achievement.AchievementXtCommManager;
   import flash.display.Sprite;
   import flash.geom.Point;
   import game.MinigameManager;
   
   public class PhantomFighterPlayer
   {
      private static const SHOT_ACCELERATION:int = 2000;
      
      private static const SHOT_MAX_VELOCITY:int = 450;
      
      private static const MAX_ACCELERATION:Number = 0.5;
      
      private static const SHOT_TIME:Number = 0.4;
      
      private static const SHOT_TIME_RAPID:Number = 0.2;
      
      private static const SHOT_TIME_TRIPLE:Number = 0.4;
      
      private static const SHOT_TIME_POWERFUL:Number = 1;
      
      private static const SHOT_TIME_EXPLOSIVE:Number = 1.5;
      
      private static const START_POS_X:int = 400;
      
      private static const START_POS_Y:int = 450;
      
      public var _theGame:PhantomFighter;
      
      public var _clone:Object;
      
      public var _lastFrameVelocity:Point;
      
      public var _serverVelocity:Point;
      
      public var _serverAcceleration:Point;
      
      public var _serverPosition:Point;
      
      public var _shotTimer:Number;
      
      public var _type:int;
      
      public var _debugCircle:Sprite;
      
      public var _powerupsUsed:Array;
      
      public var _levelsWithNoDeath:int;
      
      public function PhantomFighterPlayer(param1:PhantomFighter)
      {
         super();
         _theGame = param1;
      }
      
      public function init() : void
      {
         _powerupsUsed = new Array(true,false,false,false,false);
         _levelsWithNoDeath = 0;
         _lastFrameVelocity = new Point();
         _serverVelocity = new Point();
         _serverAcceleration = new Point();
         _serverPosition = new Point();
         _clone = _theGame.getScene().getLayer("player");
         _clone.loader.x = 400;
         _clone.loader.y = 450;
         _serverPosition.x = _clone.loader.x;
         _serverPosition.y = _clone.loader.y;
         _theGame._layerPlayers.addChild(_clone.loader);
         _shotTimer = 0;
         _type = 0;
         _clone.loader.content.shieldOn();
      }
      
      public function remove() : void
      {
         if(_clone && _clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(Math.abs(_theGame._targetPosX - _clone.loader.x) < 1)
         {
            _clone.loader.x = _theGame._targetPosX;
         }
         else
         {
            _loc3_ = (_clone.loader.x - _theGame._targetPosX) * 0.5;
            _clone.loader.x -= _loc3_;
         }
         if(Math.abs(_theGame._targetPosY - _clone.loader.y) < 1)
         {
            _clone.loader.y = _theGame._targetPosY;
         }
         else
         {
            _loc2_ = (_clone.loader.y - _theGame._targetPosY) * 0.5;
            _clone.loader.y -= _loc2_;
         }
         if(_shotTimer > 0)
         {
            _shotTimer -= param1;
         }
      }
      
      public function shoot() : void
      {
         var _loc1_:Object = null;
         if(_shotTimer <= 0)
         {
            _clone.loader.content.shoot();
            switch(_type)
            {
               case 0:
                  _shotTimer = 0.4;
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_normal_left.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_normal_left.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 0;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_normal_right.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_normal_right.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 0;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _theGame._soundMan.playByName(_theGame._soundNameVehFire);
                  break;
               case 1:
                  _shotTimer = 1;
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_powerful.x - _theGame.getScene().getLayer("projectile_powerful").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_powerful.y - _theGame.getScene().getLayer("projectile_powerful").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _theGame._soundMan.playByName(_theGame._soundNameElectricTornadoFire);
                  break;
               case 2:
                  _shotTimer = 0.4;
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_triple_left.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_triple_left.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = -1;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_normal_center.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_normal_center.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 0;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_triple_right.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_triple_right.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 1;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _theGame._soundMan.playByName(_theGame._soundNameVehFire);
                  break;
               case 3:
                  _shotTimer = 1.5;
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_explosive.x - _theGame.getScene().getLayer("projectile_explosive").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_explosive.y - _theGame.getScene().getLayer("projectile_explosive").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _theGame._soundMan.playByName(_theGame._soundNameBombProjectileFire);
                  break;
               case 4:
                  _shotTimer = 0.2;
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_rapid_left.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_rapid_left.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 0;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _loc1_ = _theGame.getNewShot(_type);
                  _loc1_.clone.loader.x = _clone.loader.x + _clone.loader.content.placement_rapid_right.x - _theGame.getScene().getLayer("projectile").loader.content.position.x;
                  _loc1_.clone.loader.y = _clone.loader.y + _clone.loader.content.placement_rapid_right.y - _theGame.getScene().getLayer("projectile").loader.content.position.y;
                  _loc1_.acceleration = 2000;
                  _loc1_.maxvelocity = 450;
                  _loc1_.velocity = 450;
                  _loc1_.angle = 0;
                  _loc1_.lastPosX = _loc1_.clone.loader.x;
                  _loc1_.lastPosY = _loc1_.clone.loader.y;
                  _loc1_.type = _type;
                  _theGame.addPlayerShot(_loc1_);
                  _theGame._soundMan.playByName(_theGame._soundNameVehFire);
            }
         }
      }
      
      public function die() : void
      {
         _clone.loader.content.die();
         _theGame._soundMan.playByName(_theGame._soundNameVehDeath);
      }
      
      public function revive() : void
      {
         _levelsWithNoDeath = 0;
         _clone.loader.content.revive();
         _clone.loader.x = 400;
         _clone.loader.y = 450;
      }
      
      public function upgrade(param1:String) : void
      {
         switch(param1.charAt(0))
         {
            case "n":
               _type = 0;
               break;
            case "p":
               _type = 1;
               break;
            case "t":
               _type = 2;
               break;
            case "e":
               _type = 3;
               break;
            case "r":
               _type = 4;
         }
         _powerupsUsed[_type] = true;
         _clone.loader.content.upgrade(param1);
         if(_powerupsUsed[0] == true && _powerupsUsed[1] == true && _powerupsUsed[2] == true && _powerupsUsed[3] == true && _powerupsUsed[4] == true)
         {
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               AchievementXtCommManager.requestSetUserVar(84,1);
               _theGame._displayAchievementTimer = 1;
            }
         }
      }
      
      public function setBoost(param1:Boolean) : void
      {
         if(param1)
         {
            _clone.loader.content.boostOn();
         }
         else
         {
            _clone.loader.content.boostOff();
         }
      }
      
      public function Retry() : void
      {
         _levelsWithNoDeath = 0;
         _powerupsUsed = new Array(true,false,false,false,false);
      }
   }
}

