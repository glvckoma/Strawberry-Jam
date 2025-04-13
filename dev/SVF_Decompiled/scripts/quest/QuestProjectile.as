package quest
{
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   
   public class QuestProjectile extends Sprite
   {
      private static const PROJECTILE_VELOCITY:int = 400;
      
      private static const PROJECTILE_RANGE:int = 600;
      
      private static const PROJECTILE_RADIUS:int = 10;
      
      private var _projectileVelocity:int;
      
      private var _projectileRange:int;
      
      private var _weaponItem:Object;
      
      private var _npc:QuestActor;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _strikeMC:MovieClip;
      
      private var _projectileMC:MovieClip;
      
      private var _aimX:Number;
      
      private var _aimY:Number;
      
      private var _distanceTravelled:Number;
      
      private var _timer:Number;
      
      private var _angle:Number;
      
      private var _collisionOffset:Point;
      
      private var _color:uint;
      
      private var _localPlayerLaunched:Boolean;
      
      private var _healProjectile:Boolean;
      
      public function QuestProjectile()
      {
         super();
         _distanceTravelled = 0;
         _timer = 0;
      }
      
      public function get angle() : Number
      {
         return _angle;
      }
      
      public function destroy() : void
      {
         if(_strikeMC != null && _strikeMC.parent != null)
         {
            _strikeMC.parent.removeChild(_strikeMC);
         }
         if(_mediaHelperObj != null)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
         _strikeMC.weapon.rotation = 0;
         QuestManager.recycle(_weaponItem.attackMediaRefId,this);
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc6_:QuestActor = null;
         var _loc4_:AvatarWorldView = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_timer == 0)
         {
            if(_projectileMC != null)
            {
               x += _aimX * _projectileVelocity * param1;
               y += _aimY * _projectileVelocity * param1;
               _distanceTravelled += _projectileVelocity * param1;
               if(_distanceTravelled > _projectileRange || RoomManagerWorld.instance.collisionTestGrid(x + _collisionOffset.x,y + _collisionOffset.y) == 1)
               {
                  handleHit(true,null,null,false);
               }
               else if(_npc != null || _healProjectile)
               {
                  for(var _loc5_ in AvatarManager.avatarViewList)
                  {
                     _loc4_ = AvatarManager.avatarViewList[_loc5_];
                     if(_loc4_ != null)
                     {
                        _loc2_ = x + _collisionOffset.x - (_loc4_.x + -15);
                        _loc3_ = y + _collisionOffset.y - (_loc4_.y + -40);
                        if(_loc2_ * _loc2_ + _loc3_ * _loc3_ < (10 + 50) * (10 + 50))
                        {
                           handleHit(false,null,_loc4_,_localPlayerLaunched);
                        }
                     }
                  }
                  _loc6_ = QuestManager.projectileRadiusCheck(x + _collisionOffset.x,y + _collisionOffset.y,10);
                  if(_loc6_ != null && _loc6_ != _npc)
                  {
                     handleHit(false,_loc6_,null,true);
                  }
               }
               else
               {
                  _loc6_ = QuestManager.projectileRadiusCheck(x + _collisionOffset.x,y + _collisionOffset.y,10);
                  if(_loc6_ != null)
                  {
                     handleHit(false,_loc6_,null,_localPlayerLaunched);
                  }
               }
            }
         }
         else
         {
            _timer -= param1;
            if(_timer <= 0)
            {
               _timer = 0;
               return true;
            }
         }
         return false;
      }
      
      public function handleHit(param1:Boolean, param2:QuestActor, param3:AvatarWorldView, param4:Boolean) : void
      {
         var _loc5_:Point = null;
         _projectileMC.visible = false;
         _timer = 2;
         if(param1 == false)
         {
            if(param2 != null)
            {
               param2.handleHit(param4,_weaponItem.defId);
               _loc5_ = param2.actorOffset;
               x = param2.x + _loc5_.x;
               y = param2.y + _loc5_.y;
            }
            else
            {
               if(!_healProjectile)
               {
                  if(param3 == AvatarManager.playerAvatarWorldView)
                  {
                     QuestManager.questActorAttacked("",_weaponItem.defId,0,0,_npc);
                  }
               }
               else if(_localPlayerLaunched)
               {
                  QuestXtCommManager.questPlayerHeal(_weaponItem.defId,param3.avatarData.sfsUserId);
               }
               _loc5_ = new Point(-15,-40);
               x = _loc5_.x + param3.x;
               y = _loc5_.y + param3.y;
            }
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_weaponItem.attackMediaRefId,onEffectLoaded);
         }
      }
      
      private function setAngle() : void
      {
         var _loc2_:Number = _aimX - x;
         var _loc1_:Number = _aimY - y;
         if(_loc2_ == 0 && _loc1_ == 0)
         {
            _loc2_ = 1;
         }
         var _loc3_:Number = Math.sqrt(_loc2_ * _loc2_ + _loc1_ * _loc1_);
         _aimX = _loc2_ / _loc3_;
         _aimY = _loc1_ / _loc3_;
         var _loc4_:Number = Math.asin(_aimX);
         if(_aimY > 0)
         {
            _loc4_ = -(3.141592653589793 + _loc4_);
         }
         _angle = _loc4_ * 180 / 3.141592653589793;
      }
      
      public function relaunch(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc8_:Point = null;
         _color = param2;
         _aimX = param4;
         _aimY = param5;
         _healProjectile = false;
         _distanceTravelled = 0;
         _timer = 0;
         if(param6 == null)
         {
            if(param7)
            {
               _localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(_localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(_weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               _healProjectile = _weaponItem.attack < 0;
               x = _strikeMC.x = param7.x + -15;
               y = _strikeMC.y = param7.y + -40;
               setAngle();
               _strikeMC.strike(_angle);
               param3.addChild(_strikeMC);
               _projectileMC.visible = true;
               _projectileMC.projectile(_angle);
            }
         }
         else
         {
            _localPlayerLaunched = false;
            _loc8_ = param6.actorOffset;
            _npc = param6;
            x = _strikeMC.x = _npc.x + _loc8_.x;
            y = _strikeMC.x = _npc.y + _loc8_.y;
            setAngle();
            _strikeMC.strike(_angle);
            param3.addChild(_strikeMC);
            _projectileMC.visible = true;
            _projectileMC.projectile(_angle);
         }
         param3.addChild(this);
         return true;
      }
      
      public function launch(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc8_:Object = null;
         var _loc12_:Point = null;
         var _loc11_:Array = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         _color = param2;
         _weaponItem = ItemXtCommManager.getItemDef(param1);
         _aimX = param4;
         _aimY = param5;
         _healProjectile = false;
         if(param6 == null)
         {
            if(param7)
            {
               _localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(_localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestProjectileLaunch(_weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               _loc8_ = ItemXtCommManager.getItemDef(param1);
               if(_loc8_)
               {
                  _healProjectile = _loc8_.attack < 0;
               }
               x = param7.x + -15;
               y = param7.y + -40;
               _mediaHelperObj = new MediaHelper();
               _mediaHelperObj.init(_weaponItem.attackMediaRefId,onStrikeLoaded);
            }
         }
         else
         {
            _localPlayerLaunched = false;
            _loc12_ = param6.actorOffset;
            _npc = param6;
            x = _npc.x + _loc12_.x;
            y = _npc.y + _loc12_.y;
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_weaponItem.attackMediaRefId,onStrikeLoaded);
            _projectileVelocity = 400;
            _projectileRange = 600;
            if(param6._actorData.extendedParameters != null)
            {
               _loc11_ = param6._actorData.extendedParameters.split(",");
               _loc10_ = 0;
               while(_loc10_ < _loc11_.length)
               {
                  switch((_loc9_ = _loc11_[_loc10_].split("="))[0])
                  {
                     case "projectilerange":
                        _projectileRange = int(_loc9_[1]);
                        break;
                     case "projectilevelocity":
                        _projectileVelocity = int(_loc9_[1]);
                  }
                  _loc10_++;
               }
            }
         }
         if(_mediaHelperObj != null)
         {
            setAngle();
            param3.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onStrikeLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         if(parent != null)
         {
            _loc2_ = PaletteHelper.getRGBColors(_color);
            _loc3_ = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
            param1.rgbColors = _loc3_;
            param1.setColors();
            param1.x += x;
            param1.y += y;
            param1.strike(_angle);
            parent.addChild(param1);
            _strikeMC = param1;
            if(_mediaHelperObj != null)
            {
               _mediaHelperObj.destroy();
               _mediaHelperObj = null;
            }
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_weaponItem.attackMediaRefId,onProjectileLoaded);
         }
      }
      
      private function onEffectLoaded(param1:MovieClip) : void
      {
         addChild(param1);
         param1.effect();
         if(_mediaHelperObj != null)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
      }
      
      private function onProjectileLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = PaletteHelper.getRGBColors(_color);
         var _loc3_:Array = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
         param1.rgbColors = _loc3_;
         param1.setColors();
         _projectileMC = param1;
         addChild(_projectileMC);
         _projectileMC.projectile(_angle);
         _collisionOffset = _projectileMC.getCollisionPoint();
         if(_mediaHelperObj != null)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
      }
   }
}

