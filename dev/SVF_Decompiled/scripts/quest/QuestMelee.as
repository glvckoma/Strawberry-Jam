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
   
   public class QuestMelee extends Sprite
   {
      private var _weaponItem:Object;
      
      private var _npc:QuestActor;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _swipeMC:MovieClip;
      
      private var _localPlayerLaunched:Boolean;
      
      private var _angle:Number;
      
      private var _timer:Number;
      
      private var _meleeID:int;
      
      private var _players:Array;
      
      private var _color:uint;
      
      public function QuestMelee(param1:int)
      {
         super();
         _meleeID = param1;
      }
      
      public function get angle() : Number
      {
         return _angle;
      }
      
      public function destroy() : void
      {
         if(_mediaHelperObj != null)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function heartbeat(param1:Number) : Boolean
      {
         var _loc2_:Point = null;
         var _loc8_:Array = null;
         var _loc7_:* = null;
         var _loc6_:int = 0;
         var _loc5_:AvatarWorldView = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_timer > 0)
         {
            _timer -= param1;
            if(_timer <= 0)
            {
               return true;
            }
         }
         else if(_swipeMC != null)
         {
            if(_swipeMC.weaponDone)
            {
               _timer = 2;
            }
            else if(_swipeMC.hitActive)
            {
               _loc2_ = _swipeMC.getCollisionPoint();
               _loc2_.x += x;
               _loc2_.y += y;
               if(_npc != null)
               {
                  if(_players)
                  {
                     _loc6_ = _players.length - 1;
                     while(_loc6_ >= 0)
                     {
                        _loc5_ = AvatarManager.avatarViewList[_players[_loc6_]];
                        if(_loc5_ != null)
                        {
                           _loc3_ = _loc2_.x - (_loc5_.x + -15);
                           _loc4_ = _loc2_.y - (_loc5_.y + -40);
                           if(_loc3_ * _loc3_ + _loc4_ * _loc4_ < (_swipeMC.radius + 50) * (_swipeMC.radius + 50))
                           {
                              handleHit(null,_loc5_,_localPlayerLaunched);
                              _players.splice(_loc6_,1);
                           }
                        }
                        else
                        {
                           _players.splice(_loc6_,1);
                        }
                        _loc6_--;
                     }
                  }
                  _loc8_ = QuestManager.meleeRadiusCheck(_meleeID,_loc2_,_swipeMC.radius,2,_npc);
                  if(_loc8_ != null)
                  {
                     for each(_loc7_ in _loc8_)
                     {
                        handleHit(_loc7_,null,true);
                     }
                  }
               }
               else
               {
                  _loc8_ = QuestManager.meleeRadiusCheck(_meleeID,_loc2_,_swipeMC.radius,1);
                  if(_loc8_ != null)
                  {
                     for each(_loc7_ in _loc8_)
                     {
                        handleHit(_loc7_,null,_localPlayerLaunched);
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function handleHit(param1:QuestActor, param2:AvatarWorldView, param3:Boolean) : void
      {
         var _loc5_:Point = null;
         if(param1 != null)
         {
            param1.handleHit(param3,_weaponItem.defId);
            _loc5_ = param1.actorOffset;
            _loc5_.x = _loc5_.x + (param1.x - x);
            _loc5_.y += param1.y - y;
         }
         else
         {
            if(param2 == AvatarManager.playerAvatarWorldView)
            {
               QuestManager.questActorAttacked("",_weaponItem.defId,0,0,_npc);
            }
            _loc5_ = new Point(-15,-40);
            _loc5_.x = _loc5_.x + (param2.x - x);
            _loc5_.y += param2.y - y;
         }
         var _loc4_:MediaHelper = new MediaHelper();
         _loc4_.init(_weaponItem.attackMediaRefId,onEffectLoaded,_loc5_);
      }
      
      public function swipe(param1:int, param2:uint, param3:Sprite, param4:int, param5:int, param6:QuestActor, param7:AvatarView) : Boolean
      {
         var _loc11_:Point = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         _weaponItem = ItemXtCommManager.getItemDef(param1);
         _color = param2;
         if(param6 == null)
         {
            if(param7 != null)
            {
               _localPlayerLaunched = param7.userId == AvatarManager.playerSfsUserId;
               if(_localPlayerLaunched)
               {
                  QuestXtCommManager.sendQuestSwipe(_weaponItem.defId,param4,param5,"",param7.userId,param2);
               }
               x = param7.x + -15;
               y = param7.y + -40;
               _mediaHelperObj = new MediaHelper();
               _mediaHelperObj.init(_weaponItem.attackMediaRefId,onSwipeLoaded,this);
            }
         }
         else
         {
            _localPlayerLaunched = false;
            _players = [];
            for(var _loc13_ in AvatarManager.avatarViewList)
            {
               _players.push(_loc13_);
            }
            _loc11_ = param6.actorOffset;
            _npc = param6;
            x = _npc.x + _loc11_.x;
            y = _npc.y + _loc11_.y;
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_weaponItem.attackMediaRefId,onSwipeLoaded,this);
         }
         if(_mediaHelperObj != null)
         {
            _loc9_ = param4 - x;
            _loc8_ = param5 - y;
            if(_loc9_ == 0 && _loc8_ == 0)
            {
               _loc9_ = 1;
            }
            _loc10_ = Math.sqrt(_loc9_ * _loc9_ + _loc8_ * _loc8_);
            _loc9_ /= _loc10_;
            _loc8_ /= _loc10_;
            _loc12_ = Math.asin(_loc9_);
            if(_loc8_ > 0)
            {
               _loc12_ = -(3.141592653589793 + _loc12_);
            }
            _angle = _loc12_ * 180 / 3.141592653589793;
            param3.addChild(this);
            return true;
         }
         return false;
      }
      
      private function onEffectLoaded(param1:MovieClip) : void
      {
         param1.x = param1.passback.x;
         param1.y = param1.passback.y;
         param1.effect();
         addChild(param1);
         param1.mediaHelper.destroy();
      }
      
      private function onSwipeLoaded(param1:MovieClip) : void
      {
         var _loc2_:Array = PaletteHelper.getRGBColors(_color);
         var _loc3_:Array = new Array(new Array(_loc2_[0].r,_loc2_[0].g,_loc2_[0].b),new Array(_loc2_[1].r,_loc2_[1].g,_loc2_[1].b),new Array(_loc2_[2].r,_loc2_[2].g,_loc2_[2].b),new Array(_loc2_[3].r,_loc2_[3].g,_loc2_[3].b));
         param1.rgbColors = _loc3_;
         param1.setColors();
         addChild(param1);
         param1.strike(_angle);
         _swipeMC = param1;
         param1.mediaHelper.destroy();
      }
   }
}

