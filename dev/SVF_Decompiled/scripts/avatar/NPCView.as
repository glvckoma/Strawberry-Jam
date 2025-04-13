package avatar
{
   import collection.AccItemCollection;
   import com.sbi.graphics.LayerAnim;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   
   public class NPCView extends Sprite
   {
      public static const NPC_STATE_LOADING:int = -2;
      
      public static const NPC_STATE_LOADED:int = -1;
      
      public static const NPC_STATE_IDLE:int = 0;
      
      public static const NPC_STATE_MOVE:int = 1;
      
      public static const NPC_STATE_ATTACK:int = 2;
      
      public static const NPC_STATE_RECOIL:int = 3;
      
      public static const NPC_STATE_DEATH:int = 4;
      
      public static const NPC_STATE_TREASURE_APPEAR:int = 5;
      
      public static const NPC_STATE_TREASURE_OPEN:int = 6;
      
      public static const NPC_STATE_TREASURE_DISAPPEAR:int = 7;
      
      public static const NPC_STATE_DANCE:int = 8;
      
      private var _npcDef:Object;
      
      private var _npcMC:MovieClip;
      
      private var _npcAvatarView:AvatarWorldView;
      
      private var _playerId:int;
      
      private var _namebar:NameBar;
      
      private var _mediaHelperObj:MediaHelper;
      
      private var _onLoadingCompleteCallback:Function;
      
      private var _npcState:int;
      
      private var _npcAngle:int;
      
      private var _healthBar:MovieClip;
      
      private var _hitText:TextField;
      
      private var _hitTextTween:GTween;
      
      private var _secondaryNpcMC:MovieClip;
      
      public var _torch:MovieClip;
      
      public var _eye:MovieClip;
      
      public var _beam:MovieClip;
      
      public var _npcFacingSW:Boolean;
      
      public var _npcAttackTriggered:Boolean;
      
      public function NPCView()
      {
         super();
      }
      
      public function get npcState() : int
      {
         return _npcState;
      }
      
      public function get npcStateComplete() : Boolean
      {
         switch(_npcState - -2)
         {
            case 0:
               return false;
            case 1:
               return true;
            case 7:
            case 8:
            case 9:
               return _npcMC == null || _npcMC.finished;
            default:
               throw new Error("NPVView: npcStateComplete: Unsupported state");
         }
      }
      
      public function get readyToLaunchAttack() : Boolean
      {
         if(_npcState == 2)
         {
            if(_npcMC != null)
            {
               if(_npcMC.attacking == true)
               {
                  _npcMC.attacking = false;
                  return true;
               }
               if(_npcMC.hasOwnProperty("counterAttacking") && _npcMC.counterAttacking == true)
               {
                  _npcMC.counterAttacking = false;
                  return true;
               }
            }
            return false;
         }
         return true;
      }
      
      public function get readyToAttack() : Boolean
      {
         var _loc2_:Array = null;
         var _loc1_:int = 0;
         var _loc3_:Object = null;
         if(_npcMC != null && Boolean(_npcMC.hasOwnProperty("getCustomCollisionPoints")))
         {
            _loc2_ = _npcMC.getCustomCollisionPoints();
            if(_loc2_ != null)
            {
               _loc1_ = 0;
               while(_loc1_ < _loc2_.length)
               {
                  _loc3_ = _loc2_[_loc1_];
                  if(_loc3_.Type == 2)
                  {
                     return !_npcMC.animActive && _npcMC.readyForAttack;
                  }
                  _loc1_++;
               }
            }
         }
         if(_npcState != 2 && _npcState != 4)
         {
            return true;
         }
         return false;
      }
      
      public function getIsDead() : Boolean
      {
         if(_npcState == 4 && (_npcMC == null || _npcMC.animActive == false))
         {
            return true;
         }
         return false;
      }
      
      public function get isDying() : Boolean
      {
         return _npcState == 4;
      }
      
      public function moveFaceAnim(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         if(_npcAvatarView)
         {
            _loc3_ = 0;
            _loc2_ = false;
            while(param1 < 0)
            {
               param1 += 360;
            }
            while(param1 >= 360)
            {
               param1 -= 360;
            }
            if(RoomManagerWorld.instance.roomEnviroType == 0)
            {
               if(param1 < 180)
               {
                  if(param1 < 35)
                  {
                     _loc3_ = 7;
                  }
                  else if(param1 < 70)
                  {
                     _loc3_ = 8;
                  }
                  else if(param1 < 110)
                  {
                     _loc3_ = 9;
                  }
                  else if(param1 < 145)
                  {
                     _loc3_ = 10;
                  }
                  else
                  {
                     _loc3_ = 11;
                  }
               }
               else
               {
                  _loc2_ = true;
                  if(param1 < 215)
                  {
                     _loc3_ = 11;
                  }
                  else if(param1 < 250)
                  {
                     _loc3_ = 10;
                  }
                  else if(param1 < 290)
                  {
                     _loc3_ = 9;
                  }
                  else if(param1 < 325)
                  {
                     _loc3_ = 8;
                  }
                  else
                  {
                     _loc3_ = 7;
                  }
               }
            }
            else if(RoomManagerWorld.instance.roomEnviroType == 1)
            {
               if(param1 < 180)
               {
                  _loc3_ = 29;
               }
               else
               {
                  _loc2_ = true;
                  _loc3_ = 29;
               }
            }
            _npcAvatarView.playAnim(_loc3_,_loc2_,2);
         }
      }
      
      public function setNpcState(param1:int, param2:Number = 0) : void
      {
         if(_npcState != 4)
         {
            switch(param1)
            {
               case 0:
                  if(_npcMC)
                  {
                     if(_npcMC.animActive == false)
                     {
                        _npcState = param1;
                        _npcMC.idle(param2 == 0 ? 270 : param2);
                     }
                     if(_npcMC.hasOwnProperty("getSortHeight"))
                     {
                        if(_npcMC.parent.parent)
                        {
                           _npcMC.parent.parent.name = _npcMC.getSortHeight();
                        }
                     }
                     break;
                  }
                  if(_npcAvatarView)
                  {
                     if(_npcState != param1)
                     {
                        if(RoomManagerWorld.instance.roomEnviroType == 0)
                        {
                           playAnimationState(14,false,0,null);
                        }
                        else if(RoomManagerWorld.instance.roomEnviroType == 1)
                        {
                           playAnimationState(32,false,0,null);
                        }
                        _npcState = param1;
                     }
                  }
                  break;
               case 1:
                  if(_npcAvatarView != null)
                  {
                     _npcState = param1;
                     if(_npcAngle != param2)
                     {
                        _npcAngle = param2;
                        moveFaceAnim(_npcAngle);
                     }
                     break;
                  }
                  if(_npcMC != null)
                  {
                     _npcAngle = param2;
                     if(_npcMC.animActive == false)
                     {
                        _npcState = param1;
                        _npcMC.moveCycle(_npcAngle);
                     }
                  }
                  break;
               case 2:
                  if(_npcMC != null)
                  {
                     _npcAttackTriggered = false;
                     _npcState = param1;
                     _npcAngle = param2;
                     _npcMC.attack(_npcAngle);
                  }
                  break;
               case 3:
                  if(_npcMC != null)
                  {
                     if(_npcState != 3 || _npcMC.hasOwnProperty("animActive") == false || _npcMC.animActive == false)
                     {
                        if(_npcState == 0 || _npcState == 1)
                        {
                           _npcState = param1;
                        }
                        _npcMC.recoil(_npcAngle);
                     }
                  }
                  break;
               case 4:
                  if(_npcMC)
                  {
                     _npcState = param1;
                     _npcMC.noHealth();
                  }
                  break;
               case 5:
                  if(_npcMC)
                  {
                     _npcMC.appear();
                     _npcState = param1;
                  }
                  break;
               case 6:
                  if(_npcMC)
                  {
                     _npcMC.openChest();
                     _npcState = param1;
                  }
                  break;
               case 7:
                  if(_npcMC)
                  {
                     _npcMC.disappear();
                     _npcState = param1;
                  }
                  break;
               case 8:
                  if(_npcAvatarView != null)
                  {
                     _npcState = param1;
                     if(RoomManagerWorld.instance.roomEnviroType == 0)
                     {
                        playAnimationState(23,false,0,null);
                        break;
                     }
                     if(RoomManagerWorld.instance.roomEnviroType == 1)
                     {
                        playAnimationState(38,false,0,null);
                     }
                     break;
                  }
            }
         }
      }
      
      public function get collisionZapRadius() : Number
      {
         if(_npcMC != null)
         {
            if("getCollisionRadius" in _npcMC)
            {
               return _npcMC.getCollisionRadius(0);
            }
         }
         return 20;
      }
      
      public function get collisionRadiusMoving() : Number
      {
         if(_npcMC != null)
         {
            if("getCollisionRadius" in _npcMC)
            {
               return _npcMC.getCollisionRadius(1);
            }
         }
         return 20;
      }
      
      public function get collisionRadiusAttack() : Number
      {
         if(_npcMC != null)
         {
            if("getCollisionRadius" in _npcMC)
            {
               return _npcMC.getCollisionRadius(2);
            }
         }
         return 20;
      }
      
      public function get collisionMovingPoint() : Point
      {
         if(_npcMC != null)
         {
            if("getCollisionPoint" in _npcMC)
            {
               return _npcMC.getCollisionPoint(1);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionZapPoint() : Point
      {
         if(_npcMC != null)
         {
            if("getCollisionPoint" in _npcMC)
            {
               return _npcMC.getCollisionPoint(2);
            }
         }
         return new Point(0,0);
      }
      
      public function get collisionPointAttack() : Point
      {
         if(_npcMC != null)
         {
            if("getCollisionPoint" in _npcMC)
            {
               return _npcMC.getCollisionPoint(0);
            }
         }
         return new Point(0,0);
      }
      
      public function get currAvatar() : Avatar
      {
         if(_npcAvatarView != null)
         {
            return _npcAvatarView.avatarData;
         }
         return null;
      }
      
      public function get talkingHeadMediaId() : int
      {
         if(_npcDef != null)
         {
            return _npcDef.headMediaRefId;
         }
         return 0;
      }
      
      public function reset() : void
      {
         _npcState = -2;
      }
      
      public function init(param1:int, param2:int, param3:int = -1, param4:int = 0, param5:Boolean = false, param6:Function = null) : void
      {
         var _loc14_:Avatar = null;
         var _loc12_:String = null;
         var _loc13_:AccItemCollection = null;
         var _loc7_:int = 0;
         var _loc9_:Item = null;
         var _loc8_:int = 0;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         _npcFacingSW = false;
         _npcState = -2;
         _npcAngle = 0;
         _npcDef = QuestManager.getNPCDef(param1);
         _playerId = param2;
         _onLoadingCompleteCallback = param6;
         _hitText = new TextField();
         _hitText.selectable = false;
         _hitText.multiline = false;
         _hitText.autoSize = "center";
         _hitText.visible = false;
         _hitText.embedFonts = true;
         _hitText.defaultTextFormat = new TextFormat("TikiIsland-Regular",36,4286945);
         _hitText.filters = [new GlowFilter(0,1,3,3,10,2)];
         switch(_npcDef.type)
         {
            case 0:
               _mediaHelperObj = new MediaHelper();
               _mediaHelperObj.init(_npcDef.mediaRefId,onMediaLoaded);
               break;
            case 1:
               _loc14_ = new Avatar();
               _loc14_.avName = "";
               _loc14_.userName = "";
               _loc14_.isShaman = param4 == 32;
               _npcAvatarView = new AvatarWorldView();
               _npcAvatarView.initWorldView(_loc14_,QuestManager._layerManager.room_chat,1,true);
               _loc14_.init(-1,-1,_loc14_.avName,_npcDef.avatarRefId,[_npcDef.baseColor,_npcDef.patternColor,_npcDef.eyesColor]);
               _loc14_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(_npcDef.avatarRefId,_npcDef.patternItemRefId,_npcDef.eyesItemRefId,false));
               if(param3 > 0)
               {
                  if(_npcAvatarView != null && _npcAvatarView.avatarData != null)
                  {
                     _loc12_ = LocalizationManager.translateIdOnly(param3);
                     _npcAvatarView.avatarData.avName = _loc12_;
                     _npcAvatarView.avatarData.userName = _loc12_;
                     if(_npcAvatarView.nameBar != null)
                     {
                        _npcAvatarView.nameBar.setAvName(_loc12_);
                        _npcAvatarView.nameBar.visible = true;
                     }
                  }
               }
               _loc13_ = new AccItemCollection();
               _loc8_ = 100;
               _loc7_ = 0;
               while(_loc7_ < _npcAvatarView.avatarData.inventoryBodyMod.itemCollection.length)
               {
                  _loc13_.pushAccItem(_npcAvatarView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc7_));
                  _loc7_++;
               }
               if(_npcDef.backItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc10_ = ItemXtCommManager.getItemDef(_npcDef.backItemRefId).colors;
                  _loc9_.init(_npcDef.backItemRefId,_loc8_++,_loc10_[Math.min(_npcDef.backColor,_loc10_.length - 1)],EquippedAvatars.forced());
                  _loc13_.pushAccItem(_loc9_);
               }
               if(_npcDef.headItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc10_ = ItemXtCommManager.getItemDef(_npcDef.headItemRefId).colors;
                  _loc9_.init(_npcDef.headItemRefId,_loc8_++,_loc10_[Math.min(_npcDef.headColor,_loc10_.length - 1)],EquippedAvatars.forced());
                  _loc13_.pushAccItem(_loc9_);
               }
               if(_npcDef.legItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc10_ = ItemXtCommManager.getItemDef(_npcDef.legItemRefId).colors;
                  _loc9_.init(_npcDef.legItemRefId,_loc8_++,_loc10_[Math.min(_npcDef.legColor,_loc10_.length - 1)],EquippedAvatars.forced());
                  _loc13_.pushAccItem(_loc9_);
               }
               if(_npcDef.neckItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc10_ = ItemXtCommManager.getItemDef(_npcDef.neckItemRefId).colors;
                  _loc9_.init(_npcDef.neckItemRefId,_loc8_++,_loc10_[Math.min(_npcDef.neckColor,_loc10_.length - 1)],EquippedAvatars.forced());
                  _loc13_.pushAccItem(_loc9_);
               }
               if(_npcDef.tailItemRefId != 0)
               {
                  _loc9_ = new Item();
                  _loc10_ = ItemXtCommManager.getItemDef(_npcDef.tailItemRefId).colors;
                  _loc9_.init(_npcDef.tailItemRefId,_loc8_++,_loc10_[Math.min(_npcDef.tailColor,_loc10_.length - 1)],EquippedAvatars.forced());
                  _loc13_.pushAccItem(_loc9_);
               }
               _npcAvatarView.avatarData.itemResponseIntegrate(_loc13_);
               _loc11_ = new Array(15);
               redrawCallback(null);
         }
         if(param5)
         {
            _healthBar = GETDEFINITIONBYNAME("NPCHealth");
            _healthBar.x = -_healthBar.width * 0.5;
            _healthBar.y = 18;
            _healthBar.hpBar.width = _healthBar.hpEnemyBarContainer.width;
            addChild(_healthBar);
         }
      }
      
      public function destroy() : void
      {
         if(_mediaHelperObj)
         {
            _mediaHelperObj.destroy();
            _mediaHelperObj = null;
         }
         if(_npcMC)
         {
            if(_npcMC.hasOwnProperty("destroyPhantomNPC"))
            {
               _npcMC.destroyPhantomNPC();
            }
            if(_npcMC.parent != null)
            {
               _npcMC.parent.removeChild(_npcMC);
            }
            if(_eye && _eye.parent)
            {
               _eye.parent.removeChild(_eye);
            }
            if(_torch && _torch.parent)
            {
               _torch.parent.removeChild(_torch);
            }
         }
         if(_secondaryNpcMC && _secondaryNpcMC.parent != null && _secondaryNpcMC.parent is MovieClip)
         {
            _secondaryNpcMC.parent.removeChild(_secondaryNpcMC);
         }
         if(_namebar)
         {
            _namebar.destroy();
            _namebar = null;
         }
         if(_healthBar)
         {
            _healthBar = null;
         }
         if(_npcAvatarView)
         {
            if(_npcAvatarView.parent != null)
            {
               _npcAvatarView.parent.removeChild(_npcAvatarView);
            }
            _npcAvatarView.destroy(true);
         }
         _hitTextTween = null;
         _hitText.visible = false;
      }
      
      public function updateHealthBar(param1:int, param2:int, param3:Boolean, param4:Boolean) : void
      {
         var _loc5_:String = null;
         if(_healthBar)
         {
            if(param1 == 0)
            {
               _healthBar.visible = false;
            }
            else
            {
               _healthBar.hpBar.width = _healthBar.hpEnemyBarContainer.width * (param1 / 100);
            }
         }
         if(param4)
         {
            if(param2 > 0 && _npcMC)
            {
               if(param3)
               {
                  _loc5_ = "Fierce!\n" + Math.abs(param2) * -1;
               }
               else
               {
                  _loc5_ = String(Math.abs(param2) * -1);
               }
               playHitText(_loc5_);
            }
         }
      }
      
      public function playHitText(param1:String) : void
      {
         var _loc2_:Point = null;
         _hitText.visible = true;
         _hitText.alpha = 2;
         _hitText.text = param1;
         try
         {
            _loc2_ = _npcMC.getAttachmentPoint();
            _hitText.x = _loc2_.x + this.x - _hitText.textWidth * 0.5;
            _hitText.y = _loc2_.y + this.y;
         }
         catch(e:Error)
         {
            _hitText.x = this.x - _hitText.textWidth * 0.5;
            _hitText.y = this.y - _hitText.textHeight;
         }
         if(parent != null)
         {
            _hitText.x += parent.x;
            _hitText.y += parent.y;
         }
         if(_hitTextTween)
         {
            _hitTextTween.resetValues({
               "y":_hitText.y - 90,
               "alpha":0
            });
            _hitTextTween.beginning();
            _hitTextTween.paused = false;
         }
         else
         {
            _hitTextTween = new GTween(_hitText,1,{
               "y":_hitText.y - 90,
               "alpha":0
            },{"ease":Linear.easeNone});
         }
      }
      
      public function playAnimationState(param1:int, param2:Boolean, param3:int, param4:Function) : void
      {
         if(_npcAvatarView)
         {
            _npcAvatarView.playAnim(param1,param2,param3,param4);
         }
      }
      
      public function getNpcMC() : MovieClip
      {
         return _npcMC;
      }
      
      public function get defId() : int
      {
         return _npcDef.defId;
      }
      
      public function get npcDef() : Object
      {
         return _npcDef;
      }
      
      public function get secondaryNpcMC() : MovieClip
      {
         return _secondaryNpcMC;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _npcMC = param1;
         addChild(_npcMC);
         if(_npcMC.hasOwnProperty("eye"))
         {
            _eye = _npcMC.eye;
         }
         if(_npcMC.hasOwnProperty("torch"))
         {
            _torch = _npcMC.torch;
         }
         if(_npcDef.headMediaRefId != 0)
         {
            _mediaHelperObj = new MediaHelper();
            _mediaHelperObj.init(_npcDef.headMediaRefId,secondaryNPCLoaded);
         }
         else
         {
            loadingComplete();
         }
      }
      
      private function secondaryNPCLoaded(param1:MovieClip) : void
      {
         if(param1.getChildAt(0) is MovieClip)
         {
            _secondaryNpcMC = MovieClip(param1.getChildAt(0));
         }
         else
         {
            _secondaryNpcMC = param1;
         }
         _mediaHelperObj.destroy();
         _mediaHelperObj = null;
         loadingComplete();
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(_npcAvatarView)
         {
            if(RoomManagerWorld.instance.roomEnviroType == 0)
            {
               playAnimationState(14,false,0,null);
            }
            else if(RoomManagerWorld.instance.roomEnviroType == 1)
            {
               playAnimationState(32,false,32,null);
            }
            addChild(_npcAvatarView);
            loadingComplete();
         }
      }
      
      private function loadingComplete() : void
      {
         _npcState = -1;
         if(_npcMC != null && Boolean(_npcMC.hasOwnProperty("setInit")))
         {
            _npcMC.setInit(QuestManager._questDifficultyLevel);
            if(_npcMC.hasOwnProperty("watcher"))
            {
               _beam = _npcMC.watcher;
            }
         }
         QuestManager._layerManager.room_chat.addChild(_hitText);
         if(_onLoadingCompleteCallback != null)
         {
            _onLoadingCompleteCallback();
         }
      }
      
      public function setSwfState(param1:String) : Number
      {
         if(_npcMC != null)
         {
            if(param1 == "facesw_k")
            {
               param1 = "facesw";
            }
            else if(param1 == "facese_k")
            {
               param1 = "facese";
            }
            return _npcMC.setStateByScript(param1);
         }
         if(_npcAvatarView != null)
         {
            if(param1 == "dance")
            {
               if(RoomManagerWorld.instance.roomEnviroType == 0)
               {
                  playAnimationState(23,_npcFacingSW,0,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == 1)
               {
                  playAnimationState(38,_npcFacingSW,0,null);
               }
            }
            else if(param1 == "sitsw")
            {
               _npcFacingSW = true;
               playAnimationState(4,_npcFacingSW,0,null);
            }
            else if(param1 == "sitse")
            {
               _npcFacingSW = false;
               playAnimationState(4,_npcFacingSW,0,null);
            }
            else if(param1 == "hop")
            {
               if(RoomManagerWorld.instance.roomEnviroType == 0)
               {
                  playAnimationState(17,_npcFacingSW,0,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == 1)
               {
                  playAnimationState(41,_npcFacingSW,0,null);
               }
            }
            else if(param1 == "spin")
            {
               if(RoomManagerWorld.instance.roomEnviroType == 1)
               {
                  playAnimationState(33,_npcFacingSW,0,null);
               }
            }
            else if(param1 == "idle" || param1 == "facese")
            {
               _npcFacingSW = false;
               if(RoomManagerWorld.instance.roomEnviroType == 0)
               {
                  playAnimationState(14,false,0,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == 1)
               {
                  playAnimationState(32,false,0,null);
               }
            }
            else if(param1 == "facesw")
            {
               _npcFacingSW = true;
               if(RoomManagerWorld.instance.roomEnviroType == 0)
               {
                  playAnimationState(14,true,0,null);
               }
               else if(RoomManagerWorld.instance.roomEnviroType == 1)
               {
                  playAnimationState(32,true,0,null);
               }
            }
            else if(param1 == "facesw_k")
            {
               if(_npcFacingSW == false && _npcAvatarView)
               {
                  _npcFacingSW = true;
                  playAnimationState(_npcAvatarView.animId,true,0,null);
               }
            }
            else if(param1 == "facese_k")
            {
               if(_npcFacingSW == true && _npcAvatarView)
               {
                  _npcFacingSW = false;
                  playAnimationState(_npcAvatarView.animId,false,0,null);
               }
            }
            else if(param1 == "sleep")
            {
               playAnimationState(22,_npcFacingSW,0,null);
            }
         }
         return 0;
      }
   }
}

