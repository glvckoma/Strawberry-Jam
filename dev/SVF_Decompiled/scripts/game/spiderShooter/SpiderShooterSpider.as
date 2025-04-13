package game.spiderShooter
{
   import flash.media.SoundChannel;
   import game.MinigameManager;
   
   public class SpiderShooterSpider
   {
      public static const SPIDER_TYPE_CLIMB:int = 1;
      
      public static const SPIDER_TYPE_WALK:int = 2;
      
      public static const SPIDER_TYPE_HANG:int = 3;
      
      public var _theGame:SpiderShooter;
      
      private var _clone:Object;
      
      private var _direction:String;
      
      private var _layer:int;
      
      private var _position:int;
      
      private var _height:String;
      
      private var _tree:int;
      
      private var _type:int;
      
      private var _speed:String;
      
      private var _active:Boolean;
      
      private var _dead:Boolean;
      
      public var _netID:int;
      
      private var _trigger:Boolean;
      
      private var _moveSound:SoundChannel;
      
      public function SpiderShooterSpider(param1:SpiderShooter)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:int, param2:Object) : void
      {
         _active = true;
         _netID = param1;
         _clone = param2;
         _trigger = false;
         _clone.loader.x = 0;
         _clone.loader.y = 0;
      }
      
      private function trigger() : void
      {
         remove();
         _active = true;
         _trigger = true;
         _dead = false;
         var _loc1_:int = Math.floor(Math.random() * 3);
         switch(_loc1_)
         {
            case 0:
               _theGame._soundMan.playByName(_theGame._soundNameSpiderEmerge1);
               break;
            case 1:
               _theGame._soundMan.playByName(_theGame._soundNameSpiderEmerge2);
               break;
            default:
               _theGame._soundMan.playByName(_theGame._soundNameSpiderEmerge3);
         }
         switch(_type - 1)
         {
            case 0:
            case 1:
               _moveSound = _theGame._soundMan.playByName(_theGame._soundNameSpiderCrawl);
               break;
            case 2:
               _moveSound = _theGame._soundMan.playByName(_theGame._soundNameSpiderAppear);
         }
      }
      
      public function triggerClimb(param1:int, param2:int, param3:String, param4:String) : void
      {
         _type = 1;
         _layer = param1;
         _tree = param2;
         _direction = param3;
         _speed = param4;
         trigger();
         switch(param1 - 1)
         {
            case 0:
               _theGame._layerActorsFront.addChild(_clone.loader);
               break;
            case 1:
               _theGame._layerActorsMid.addChild(_clone.loader);
               break;
            case 2:
               _theGame._layerActorsBack.addChild(_clone.loader);
               break;
            default:
               _active = false;
         }
      }
      
      public function triggerWalk(param1:int, param2:String, param3:String) : void
      {
         _type = 2;
         _layer = param1;
         _direction = param2;
         _speed = param3;
         trigger();
         switch(param1 - 1)
         {
            case 0:
               _theGame._layerActorsFore.addChild(_clone.loader);
               break;
            case 1:
               _theGame._layerActorsFront.addChild(_clone.loader);
               break;
            case 2:
               _theGame._layerActorsMid.addChild(_clone.loader);
               break;
            case 3:
               _theGame._layerActorsBack.addChild(_clone.loader);
               break;
            default:
               _active = false;
         }
      }
      
      public function triggerHang(param1:int, param2:int, param3:String, param4:String) : void
      {
         _type = 3;
         _layer = param1;
         _position = param2;
         _height = param3;
         _speed = param4;
         trigger();
         switch(param1 - 1)
         {
            case 0:
               _theGame._layerActorsFore.addChild(_clone.loader);
               break;
            case 1:
               _theGame._layerActorsFront.addChild(_clone.loader);
               break;
            case 2:
               _theGame._layerActorsMid.addChild(_clone.loader);
               break;
            case 3:
               _theGame._layerActorsBack.addChild(_clone.loader);
               break;
            default:
               _active = false;
         }
      }
      
      public function remove() : void
      {
         if(_clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         if(_active && _clone.loader.content)
         {
            if(_trigger)
            {
               _trigger = false;
               switch(_type - 1)
               {
                  case 0:
                     _clone.loader.content.climbTree(_layer,_tree,_direction,_speed);
                     break;
                  case 1:
                     _clone.loader.content.walk(_layer,_direction,_speed);
                     break;
                  case 2:
                     _clone.loader.content.hang(_layer,_position,_height,_speed);
               }
            }
            else if(_clone.loader.content._active == false)
            {
               _active = false;
               if(_dead)
               {
                  _dead = false;
               }
            }
         }
      }
      
      public function shoot() : void
      {
         if(_clone.loader.content && _clone.loader.content._active && _active && !_dead)
         {
            _theGame._soundMan.playByName(_theGame._soundNameSpiderDeath);
            _clone.loader.content.die();
            _dead = true;
            if(_moveSound)
            {
               _moveSound.stop();
               _moveSound = null;
            }
         }
         _theGame.updateWaveScore(1);
      }
      
      public function shot(param1:int, param2:int, param3:Number) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc4_:Array = null;
         if(_clone.loader.content && _clone.loader.content._active && _active && !_dead)
         {
            _loc5_ = _clone.loader.x + _clone.loader.content.spider.x - param1;
            _loc6_ = _clone.loader.y + _clone.loader.content.spider.y - param2;
            _loc7_ = _loc5_ * _loc5_ + _loc6_ * _loc6_;
            if(_loc7_ <= (_clone.loader.content.spider.width / 2 + param3) * (_clone.loader.content.spider.width / 2 + param3))
            {
               _loc4_ = [];
               _loc4_[0] = "hit";
               _loc4_[1] = String(_netID);
               MinigameManager.msg(_loc4_);
               return true;
            }
         }
         return false;
      }
      
      public function canRecycle() : Boolean
      {
         return _active == false && _clone.loader.content && !_clone.loader.content._active;
      }
   }
}

