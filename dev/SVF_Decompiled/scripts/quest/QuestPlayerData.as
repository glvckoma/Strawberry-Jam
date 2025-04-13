package quest
{
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.NPCView;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Linear;
   import loader.MediaHelper;
   
   public class QuestPlayerData extends Sprite
   {
      private var _levelUpHelperBottom:MediaHelper;
      
      private var _levelUpHelperTop:MediaHelper;
      
      private var _levelUpMCBottom:MovieClip;
      
      private var _levelUpMCTop:MovieClip;
      
      private var _levelUpLoaded:Boolean;
      
      public var _avatarWorldView:AvatarWorldView;
      
      private var _tintFrames:int;
      
      private var _statusText:TextField;
      
      private var _statusTextTween:GTween;
      
      private var _healingTween:GTween;
      
      private var _healingHeart:MovieClip;
      
      private var _uID:int;
      
      private var _itemEmoticonSound:SoundChannel;
      
      private var _itemEmoticonSoundName:String;
      
      private var _playerDamageMC:MovieClip;
      
      private var _playerDamageMH:MediaHelper;
      
      private var _pendingPlayerDamageMax:int;
      
      private var _pendingPlayerDamageBefore:int;
      
      private var _pendingPlayerDamageAfter:int;
      
      private var _avSwitchedNPC:NPCView;
      
      private var _avSwitchNPCID:int;
      
      private var _dropOrbMC:MovieClip;
      
      private var _dropOrbMH:MediaHelper;
      
      public function QuestPlayerData()
      {
         super();
      }
      
      private function updateAvatarStatus() : void
      {
         if(_avatarWorldView == null)
         {
            _avatarWorldView = AvatarManager.avatarViewList[_uID];
            if(_avatarWorldView)
            {
               _avatarWorldView.addChild(_statusText);
               _avatarWorldView.addChild(_healingHeart);
            }
         }
      }
      
      public function init(param1:int) : void
      {
         _uID = param1;
         _avSwitchedNPC = null;
         _statusText = new TextField();
         _statusText.multiline = false;
         _statusText.selectable = false;
         _statusText.embedFonts = true;
         _statusText.defaultTextFormat = new TextFormat("TikiIsland-Regular",36,65280);
         _statusText.filters = [new GlowFilter(0,1,3,3,10,2)];
         _statusText.visible = false;
         _healingHeart = GETDEFINITIONBYNAME("questHeartsCont");
         _healingHeart.visible = false;
         _pendingPlayerDamageMax = 0;
         _playerDamageMH = new MediaHelper();
         _playerDamageMH.init(2252,onPlayerDamageLoaded);
         updateAvatarStatus();
      }
      
      private function playLevelUpEffect() : void
      {
         if(_levelUpLoaded)
         {
            _levelUpLoaded = false;
            if(_levelUpMCTop && _levelUpMCBottom)
            {
               _levelUpMCTop.gotoAndPlay("tintOn");
               _levelUpMCTop.addEventListener("enterFrame",levelUpEnterFrameHandler);
               _levelUpMCBottom.gotoAndPlay("tintOn");
               updateAvatarStatus();
               if(_avatarWorldView)
               {
                  _avatarWorldView.setBlendColor(4290903190,7534606);
               }
               QuestManager.playSound("ajq_stingerLevelUp");
            }
         }
         else
         {
            _levelUpLoaded = true;
         }
      }
      
      public function playerDamaged(param1:int, param2:int, param3:int) : void
      {
         if(_playerDamageMC != null && _avatarWorldView != null)
         {
            if(_playerDamageMC.parent != QuestManager._layerManager.room_chat)
            {
               _pendingPlayerDamageMax = 0;
               _playerDamageMC.x = _avatarWorldView.x;
               _playerDamageMC.y = _avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(_playerDamageMC);
               _playerDamageMC.hit(param1,param2,param3);
               _playerDamageMC.addEventListener("enterFrame",playerDamageFrameHandler);
            }
         }
         else
         {
            _pendingPlayerDamageMax = param1;
            _pendingPlayerDamageBefore = param2;
            _pendingPlayerDamageAfter = param3;
         }
      }
      
      private function onPlayerDamageLoaded(param1:MovieClip) : void
      {
         _playerDamageMC = param1;
         _playerDamageMH.destroy();
         _playerDamageMH = null;
         if(_pendingPlayerDamageMax > 0)
         {
            playerDamaged(_pendingPlayerDamageMax,_pendingPlayerDamageBefore,_pendingPlayerDamageAfter);
         }
      }
      
      private function onLevelUpTopLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_levelUpMCTop && _levelUpMCTop.parent)
            {
               _levelUpMCTop.parent.removeChild(_levelUpMCTop);
            }
            _levelUpMCTop = param1;
            updateAvatarStatus();
            if(_avatarWorldView)
            {
               _levelUpMCTop.x = _avatarWorldView.x;
               _levelUpMCTop.y = _avatarWorldView.y;
               QuestManager._layerManager.room_chat.addChild(_levelUpMCTop);
            }
            playLevelUpEffect();
         }
      }
      
      private function onLevelUpBottomLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_levelUpMCBottom && _levelUpMCBottom.parent)
            {
               _levelUpMCBottom.parent.removeChild(_levelUpMCBottom);
            }
            _levelUpMCBottom = param1;
            updateAvatarStatus();
            if(_avatarWorldView)
            {
               _avatarWorldView.addChildAt(_levelUpMCBottom,0);
            }
            playLevelUpEffect();
         }
      }
      
      private function playerDamageFrameHandler(param1:Event) : void
      {
         if(_avatarWorldView)
         {
            _playerDamageMC.x = _avatarWorldView.x;
            _playerDamageMC.y = _avatarWorldView.y;
            if(_playerDamageMC != null && _playerDamageMC.finished)
            {
               _playerDamageMC.removeEventListener("enterFrame",playerDamageFrameHandler);
               if(_playerDamageMC.parent == QuestManager._layerManager.room_chat)
               {
                  QuestManager._layerManager.room_chat.removeChild(_playerDamageMC);
               }
            }
         }
      }
      
      private function levelUpEnterFrameHandler(param1:Event) : void
      {
         if(_levelUpMCTop != null)
         {
            _levelUpMCTop.x = _avatarWorldView.x;
            _levelUpMCTop.y = _avatarWorldView.y;
         }
         if(_levelUpMCTop.currentFrameLabel == "tintOff")
         {
            updateAvatarStatus();
            if(_avatarWorldView)
            {
               _avatarWorldView.setBlendColor(0);
            }
         }
         if(_levelUpMCTop.currentFrameLabel == "finished")
         {
            _levelUpMCTop.removeEventListener("enterFrame",levelUpEnterFrameHandler);
         }
      }
      
      private function onTweenComplete(param1:GTween) : void
      {
         if(_avatarWorldView)
         {
            if(_healingHeart && _healingHeart.parent && _healingHeart.parent == _avatarWorldView)
            {
               _avatarWorldView.removeChild(_healingHeart);
            }
         }
      }
      
      private function onTweenStatusTextComplete(param1:GTween) : void
      {
         if(_avatarWorldView)
         {
            if(_statusText && _statusText.parent && _statusText.parent == _avatarWorldView)
            {
               _avatarWorldView.removeChild(_statusText);
            }
         }
      }
      
      public function levelUp(param1:int) : void
      {
         if(_avatarWorldView)
         {
            _avatarWorldView.updateNameBarLevelShape(param1);
         }
         _levelUpHelperTop = new MediaHelper();
         _levelUpHelperTop.init(1823,onLevelUpTopLoaded);
         _levelUpHelperBottom = new MediaHelper();
         _levelUpHelperBottom.init(1875,onLevelUpBottomLoaded);
      }
      
      public function handleHit(param1:int) : void
      {
         var _loc2_:AvatarInfo = null;
         if(_avatarWorldView != null)
         {
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(_avatarWorldView.userName);
            if(_loc2_ != null)
            {
               if(_loc2_.questHealthPercentage > 0)
               {
                  _tintFrames = 13;
                  playHitText(String(param1));
                  if(_avatarWorldView)
                  {
                     _avatarWorldView.handleOffScreenHit();
                     addEventListener("enterFrame",hitEnterFrameHandler);
                     if(_avatarWorldView == AvatarManager.playerAvatarWorldView)
                     {
                        QuestManager.playSound("ajq_playerhit");
                     }
                  }
               }
               else if(_avatarWorldView)
               {
                  _avatarWorldView.handleOffScreenSleep();
               }
            }
         }
      }
      
      public function playHitText(param1:String) : void
      {
         updateAvatarStatus();
         if(!_avatarWorldView)
         {
         }
      }
      
      public function playStatusText(param1:String) : void
      {
         _statusText.visible = true;
         _statusText.alpha = 2;
         _statusText.text = param1;
         _statusText.x = this.x - _statusText.textWidth * 0.5 - _avatarWorldView.radius * 0.5;
         _statusText.y = this.y - _avatarWorldView.radius * 2;
         if(_statusTextTween)
         {
            _statusTextTween.resetValues({
               "y":_statusText.y - 90,
               "alpha":0
            });
            _statusTextTween.beginning();
            _statusTextTween.paused = false;
         }
         else
         {
            _statusTextTween = new GTween(_statusText,1,{
               "y":_statusText.y - 90,
               "alpha":0
            },{
               "onComplete":onTweenComplete,
               "ease":Linear.easeNone
            });
         }
      }
      
      public function handleHealing(param1:int) : void
      {
         updateAvatarStatus();
         if(_avatarWorldView)
         {
            _healingHeart.visible = true;
            _healingHeart.alpha = 2;
            _healingHeart.x = this.x - _avatarWorldView.radius * 0.5;
            _healingHeart.y = this.y - _avatarWorldView.radius * 2 - 35;
            if(_healingTween)
            {
               _healingTween.resetValues({
                  "y":_healingHeart.y,
                  "alpha":0
               });
               _healingTween.beginning();
               _healingTween.paused = false;
            }
            else
            {
               _healingTween = new GTween(_healingHeart,1.5,{
                  "y":_healingHeart.y,
                  "alpha":0
               },{
                  "onComplete":onTweenComplete,
                  "ease":Linear.easeNone
               });
            }
            _avatarWorldView.handleOffScreenSleep(true);
         }
      }
      
      public function destroy() : void
      {
         stopItemEmoticonSound();
         if(hasEventListener("enterFrame"))
         {
            removeEventListener("enterFrame",hitEnterFrameHandler);
         }
         if(_levelUpMCTop && _levelUpMCTop.hasEventListener("enterFrame"))
         {
            _levelUpMCTop.removeEventListener("enterFrame",levelUpEnterFrameHandler);
         }
         if(_playerDamageMC != null)
         {
            _playerDamageMC.removeEventListener("enterFrame",playerDamageFrameHandler);
         }
         if(_playerDamageMH != null)
         {
            _playerDamageMH.destroy();
            _playerDamageMH = null;
         }
         if(_dropOrbMH != null)
         {
            _dropOrbMH.destroy();
            _dropOrbMH = null;
         }
         if(_dropOrbMC != null)
         {
            if(_dropOrbMC.parent != null)
            {
               _dropOrbMC.parent.removeChild(_dropOrbMC);
            }
            _dropOrbMC = null;
         }
      }
      
      private function soundEnterFrameHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         if(_avatarWorldView)
         {
            if(_itemEmoticonSoundName != null)
            {
               _loc2_ = 1;
               if(_avatarWorldView != AvatarManager.playerAvatarWorldView && AvatarManager.playerAvatarWorldView)
               {
                  _loc4_ = AvatarManager.playerAvatarWorldView.x - _avatarWorldView.x;
                  _loc3_ = AvatarManager.playerAvatarWorldView.y - _avatarWorldView.y;
                  _loc5_ = _loc4_ * _loc4_ + _loc3_ * _loc3_;
                  _loc7_ = 25;
                  _loc6_ = 360000;
                  if(_loc5_ > _loc6_)
                  {
                     _loc2_ = 0;
                  }
                  else if(_loc5_ >= _loc7_)
                  {
                     _loc2_ = 1 - (_loc5_ - _loc7_) / (_loc6_ - _loc7_);
                  }
               }
               if(_loc2_ > 0)
               {
                  if(_itemEmoticonSound == null)
                  {
                     _itemEmoticonSound = QuestManager.playLoopingSound(_itemEmoticonSoundName);
                  }
                  QuestManager.setSoundLevel(_itemEmoticonSound,_loc2_,_avatarWorldView);
               }
               else if(_itemEmoticonSound != null)
               {
                  _itemEmoticonSound.stop();
                  _itemEmoticonSound = null;
               }
            }
         }
      }
      
      private function hitEnterFrameHandler(param1:Event) : void
      {
         updateAvatarStatus();
         if(_avatarWorldView)
         {
            if(_avatarWorldView.isValid())
            {
               _tintFrames--;
               switch(_tintFrames)
               {
                  case 0:
                     removeEventListener("enterFrame",hitEnterFrameHandler);
                  default:
                     break;
                  case 2:
                  case 6:
                  case 10:
                     _avatarWorldView.setBlendColor(0);
                     break;
                  case 4:
                  case 8:
                  case 12:
                     _avatarWorldView.setBlendColor(3439329279,0,true);
               }
            }
            else
            {
               removeEventListener("enterFrame",hitEnterFrameHandler);
            }
         }
      }
      
      public function stopItemEmoticonSound() : void
      {
         if(_itemEmoticonSound != null)
         {
            _itemEmoticonSound.stop();
            _itemEmoticonSound = null;
         }
         if(_itemEmoticonSoundName != null)
         {
            removeEventListener("enterFrame",soundEnterFrameHandler);
            _itemEmoticonSoundName = null;
         }
      }
      
      public function playItemEmoticonSound(param1:String) : void
      {
         stopItemEmoticonSound();
         var _loc2_:int = int(param1.lastIndexOf(".wav"));
         if(_loc2_ > 0)
         {
            param1 = param1.substring(0,_loc2_);
         }
         param1 = param1.toLowerCase();
         _itemEmoticonSoundName = param1;
         addEventListener("enterFrame",soundEnterFrameHandler);
      }
      
      public function setAvatarSwitched(param1:int) : void
      {
         updateAvatarStatus();
         if(_avSwitchedNPC != null)
         {
            if(_avSwitchedNPC.parent != null)
            {
               _avSwitchedNPC.parent.removeChild(_avSwitchedNPC);
            }
            _avSwitchedNPC.destroy();
            _avSwitchedNPC = null;
         }
         if(_avatarWorldView != null)
         {
            _avatarWorldView.showAvatar();
         }
         _avSwitchNPCID = param1;
      }
      
      public function onNpcLoaded() : void
      {
         if(_avatarWorldView != null)
         {
            if(_avSwitchedNPC != null)
            {
               _avSwitchedNPC.x = _avatarWorldView.x;
               _avSwitchedNPC.y = _avatarWorldView.y;
               _avSwitchedNPC.getNpcMC().setVision(0);
               _avSwitchedNPC.setNpcState(0);
            }
         }
      }
      
      public function playerLeftRoom() : void
      {
         if(_avSwitchedNPC != null)
         {
            if(_avSwitchedNPC.parent != null)
            {
               _avSwitchedNPC.parent.removeChild(_avSwitchedNPC);
            }
            _avSwitchedNPC.destroy();
            _avSwitchedNPC = null;
         }
         _avatarWorldView = null;
      }
      
      public function heartbeat() : void
      {
         if(_avatarWorldView != null)
         {
            if(_avSwitchedNPC != null)
            {
               if(_avSwitchedNPC.x != _avatarWorldView.x || _avSwitchedNPC.y != _avatarWorldView.y)
               {
                  _avSwitchedNPC.setNpcState(1,_avSwitchedNPC.x < _avatarWorldView.x ? 90 : 270);
                  _avSwitchedNPC.x = _avatarWorldView.x;
                  _avSwitchedNPC.y = _avatarWorldView.y;
               }
               else
               {
                  _avSwitchedNPC.setNpcState(0);
               }
            }
            else if(_avSwitchNPCID != 0)
            {
               if(_avatarWorldView.isValid())
               {
                  _avatarWorldView.hideAvatar();
                  _avSwitchedNPC = new NPCView();
                  _avSwitchedNPC.x = _avatarWorldView.x;
                  _avSwitchedNPC.y = _avatarWorldView.y;
                  _avSwitchedNPC.init(_avSwitchNPCID,0,-1,0,false,onNpcLoaded);
                  QuestManager._layerManager.room_avatars.addChild(_avSwitchedNPC);
               }
            }
            if(_dropOrbMC != null)
            {
               if(_dropOrbMC.removeMe)
               {
                  _dropOrbMC.parent.removeChild(_dropOrbMC);
                  _dropOrbMC = null;
               }
            }
         }
      }
      
      private function onDropOrbLoaded(param1:MovieClip) : void
      {
         _dropOrbMC = param1;
         _dropOrbMC.x = _avatarWorldView.x;
         _dropOrbMC.y = _avatarWorldView.y;
         QuestManager._layerManager.room_chat.addChild(_dropOrbMC);
      }
      
      public function dropOrb() : void
      {
         if(_avatarWorldView != null)
         {
            if(_dropOrbMH != null)
            {
               _dropOrbMH.destroy();
            }
            _dropOrbMH = new MediaHelper();
            _dropOrbMH.init(3588,onDropOrbLoaded);
         }
      }
   }
}

