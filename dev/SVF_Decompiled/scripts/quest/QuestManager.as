package quest
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserCommXtCommManager;
   import buddy.BuddyManager;
   import collection.AccItemCollection;
   import com.sbi.analytics.GATracker;
   import com.sbi.analytics.SBTracker;
   import com.sbi.bit.BitUtility;
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.math.Collision;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBParchmentPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.MinigameManager;
   import game.SoundManager;
   import giftPopup.GiftPopup;
   import gui.*;
   import gui.itemWindows.ItemWindowAdventure;
   import gui.itemWindows.ItemWindowNameBar;
   import item.Item;
   import item.ItemXtCommManager;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.LayerManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import ru.etcs.utils.getDefinitionNames;
   
   public class QuestManager
   {
      public static const ADVENTURE_SCRIPTS_ID:int = 201;
      
      public static const SCRIPT_EDITOR_IXM_KEYWORD:String = "adventure&";
      
      public static const QUEST_WEAPON_TYPE_MELEE:int = 0;
      
      public static const QUEST_WEAPON_TYPE_PROJECTILE:int = 1;
      
      public static const QUEST_WEAPON_TYPE_BOMB:int = 2;
      
      public static const QUEST_WEAPON_DEFAULT_MELEE:int = 123;
      
      public static const QUEST_WEAPON_DEFAULT_PROJECTILE:int = 0;
      
      public static const QUEST_PLAYER_AVATAR_OFFSETX:int = -15;
      
      public static const QUEST_PLAYER_AVATAR_OFFSETY:int = -40;
      
      public static const QUEST_PLAYER_AVATAR_RADIUS:int = 50;
      
      public static const QUEST_CMD_SET_STATE:int = 1;
      
      public static const QUEST_CMD_SAY:int = 2;
      
      public static const QUEST_CMD_ASK:int = 3;
      
      public static const QUEST_CMD_GAME:int = 4;
      
      public static const QUEST_CMD_TAKE_ITEM:int = 7;
      
      public static const QUEST_CMD_TELEPORT:int = 14;
      
      public static const QUEST_CMD_FOCUS:int = 15;
      
      public static const QUEST_CMD_ON_EXIT:int = 19;
      
      public static const QUEST_CMD_NOTIFY:int = 38;
      
      public static const QUEST_CMD_DEBUGSAY:int = 1001;
      
      public static const QUEST_TINT_TIME:Number = 0.6;
      
      public static const QUEST_TORCH_UNLITSIZE:Number = 0.7;
      
      public static const QUEST_TORCH_LITSIZE:Number = 1.3;
      
      private static const TALKING_DIALOGUE_ID:int = 1789;
      
      private static const ADVENTURE_REWARDS_ID:int = 2251;
      
      private static const ADVENTURE_GOAL_REWARDS_ID:int = 2754;
      
      public static const QUEST_ADVENTURE_TYPE_DEFAULT:int = 0;
      
      public static const QUEST_ADVENTURE_TYPE_INCREMENTAL_GOAL_SUPPORT:int = 1;
      
      public static const QUEST_ADVENTURE_TYPE_MEMBER_PRIZE_SUPPORT:int = 2;
      
      public static const QUEST_ADVENTURE_TYPE_GIFT_PICKUP_SUPPORT:int = 3;
      
      public static const QUEST_ADVENTURE_TYPE_LETTERS_MAILBOX_SUPPORT:int = 4;
      
      public static const QUEST_ADVENTURE_TYPE_LUCKY_ADVENTURE:int = 5;
      
      public static const QUEST_ADVENTURE_TYPE_EASTER_ADVENTURE:int = 6;
      
      public static const QUEST_ADVENTURE_TYPE_BITTERSWEET_ADVENTURE:int = 7;
      
      public static const QUEST_ADVENTURE_TYPE_LUCKY2_ADVENTURE:int = 8;
      
      public static const QUEST_ADVENTURE_TYPE_HOTCOLD1_ADVENTURE:int = 9;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_LUCKY:int = 3;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_EASTER:int = 4;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_EASTER_DELAY:int = 5;
      
      public static const QUEST_ADVENTURE_REWARDS_POPUP_TYPE_HOTCOLD1:int = 6;
      
      private static var _npcDefs:Object;
      
      public static var _questScriptTimeStamp:String;
      
      public static var _questActorDictionary:Dictionary;
      
      public static var _questActors:Vector.<QuestActor>;
      
      private static var _questActorsDict:Dictionary;
      
      private static var _questPlayersDict:Dictionary;
      
      private static var _questPlayersSwitched:Dictionary;
      
      private static var _questActorGroups:Dictionary;
      
      private static var _questSeeds:Dictionary;
      
      public static var _layerManager:LayerManager;
      
      private static var _lastGoodAvatarX:int;
      
      private static var _lastGoodAvatarY:int;
      
      private static var _lastClearAvatarX:int;
      
      private static var _lastClearAvatarY:int;
      
      private static var _mediaLoader:MediaHelper;
      
      private static var _talkingPopup:MovieClip;
      
      private static var _adventureJoin:AdventureJoin;
      
      private static var _privateAdventureJoin:PrivateAdventureJoin;
      
      private static var _seedInventory:SeedInventoryHandling;
      
      private static var _lastTime:Number;
      
      private static var _frameTime:Number;
      
      private static var _questProjectiles:Array;
      
      private static var _questMelees:Array;
      
      private static var _projectileKeyDown:Boolean;
      
      private static var _currentMeleeID:int;
      
      private static var _inQuestRoom:Boolean;
      
      private static var _isQuestLikeNormalRoom:Boolean;
      
      private static var _playerWeaponTimerProjectile:Number;
      
      private static var _playerWeaponTimerMelee:Number;
      
      private static var _talkingLoadingSpiral:LoadingSpiral;
      
      private static var _levelShapeHelper:MediaHelper;
      
      private static var _actorPriority:int;
      
      private static var _talkingPopupCurrTextPage:int;
      
      private static var _talkingPopupFullText:Array;
      
      private static var _questCommandActor:String;
      
      private static var _questCommandActorState:int;
      
      private static var _questExitPending:Boolean;
      
      private static var _questCommandActorMiniGame:String;
      
      private static var _questCommandActorStateMiniGame:int;
      
      private static var _soundMan:SoundManager;
      
      private static var _sounds:Dictionary;
      
      private static var _maxVolumes:Dictionary;
      
      private static var _SFX_Music:Dictionary;
      
      private static var _streamsLUT:Dictionary;
      
      private static var _SFX_AmbientSC:SoundChannel;
      
      private static var _currentMusic:String;
      
      private static var _currentAmbient:String;
      
      private static var _isLoadingTalkingPopup:Boolean;
      
      private static var _currentVOSC:SoundChannel;
      
      private static var _currentVOActor:String;
      
      private static var _globalPackLoaded:Boolean;
      
      private static var _soundPacksToLoad:Array;
      
      private static var _paused:Boolean;
      
      private static var _assetPool:Dictionary;
      
      private static var _playerLeftObjects:Array;
      
      private static var _playersWindow:WindowGenerator;
      
      private static var _playersWindowScrollBar:SBScrollbar;
      
      public static var _questScriptDefId:int;
      
      public static var _questStartingPlayerCount:int;
      
      private static var _questObjectiveText:String;
      
      private static var _defeatedPopUpTimer:Number;
      
      private static var _nearestRespawnPoint:Object;
      
      private static var _playerInStealthVolume:Boolean;
      
      private static var _playerCrystalCount:int;
      
      private static var _playerOrbCountTotal:int;
      
      private static var _gameIdleTimer:Number;
      
      private static var _kickPopup:SBOkPopup;
      
      private static var _adventureRewardsPopup:MovieClip;
      
      private static var _adventureRewardsPopupType:int;
      
      private static var _adventureRewardsPopupStatus:Array;
      
      private static var _rewardsGiftPopup:GiftPopup;
      
      private static var _hasJustJoinedQuest:Boolean;
      
      private static var _torches:Array;
      
      public static var _darknessMask:Sprite;
      
      private static var _playerTorch:MovieClip;
      
      private static var _playMusicOnLoad:Boolean;
      
      private static var _sceneLoaded:Boolean;
      
      public static var _questDifficultyLevel:int;
      
      private static var _playerAvatarCurrentAnim:int;
      
      public static var _volumeInteractionProgressing:Boolean;
      
      public static var _progressingSC:SoundChannel;
      
      public static var _progressingSCnot:SoundChannel;
      
      public static var _screenShakeSC:SoundChannel;
      
      public static var _sfxTimer:Dictionary;
      
      public static var _shaketimer:Number;
      
      public static var _shakeOrigPos:Point;
      
      public static var _playSwfMC:MovieClip;
      
      public static var _playSwfMCTimeElapsed:Number;
      
      public static var _playSwfMCSC:SoundChannel;
      
      private static var _fallingPhantomTimer:Number;
      
      private static var _fallingPhantomVolumeActors:Array;
      
      private static var _totalGemsEarned:int;
      
      private static var _totalXPEarned:int;
      
      private static var _fader:Shape;
      
      private static var _faderState:int;
      
      private static var _queueFadeIn:Boolean;
      
      private static var _availableScriptDefs:Array;
      
      private static var _adventureTimer:MovieClip;
      
      private static var _adventureHotCold:MovieClip;
      
      private static var _adventureHotColdStatus:int;
      
      private static var _adventureGoals:Array;
      
      private static var _adventureSelectPopup:MovieClip;
      
      private static var _adventureSelectScrollBar:SBScrollbar;
      
      private static var _adventureSelectItemWindow:WindowGenerator;
      
      private static var _guiElementsSkipBtn:MovieClip;
      
      private static var _guiElementsSkipBtnMh:MediaHelper;
      
      private static var _guiTimerLocal:Number;
      
      private static var _handlePickGiftDelayData:Object;
      
      private static var _handlePickGiftDelayTimer:Number;
      
      public static var _delayMinigameLaunches:Boolean;
      
      private static var _delayMinigameID:int;
      
      private static var _roomManager:RoomManagerWorld;
      
      private static var _platformScriptIdsOrdered:Array;
      
      private static var _addTorchQueue:Array = [];
      
      private static const torch:Class = §torch_swf$33fd699343d56e3498e2af6af4cbecdd-1098895790§;
      
      private static var _actorLightQueue:Array = [];
      
      private static var _fallingPhantoms:Array = [];
      
      private static var _guiElementsAvatarEditor:Array = ["gui_21","tradeBtnDown","gui_22","nonmember","gui_23","colorsTabDnBtn","gui_24","eyesTabDnBtn","gui_25","patternTabDnBtn","gui_26","bx","gui_27","sortBtn","gui_28","recycleClothesBtn","gui_29","shopBtn","gui_30","petsBtn","gui_31","colorsTabUp","gui_32","eyesTabUp","gui_33","patternTabUp","gui_38","colorTableColor1","gui_39","colorTableColor2","gui_40","colorTablePatterns","gui_41","colorTableEyes","gui_42","arrowBtnL","gui_43","arrowBtnR","gui_44","fiveMinCursor","gui_45","trophy","gui_46","money"];
      
      private static var _guiElementsGuiManager:Array = ["gui_1","eCardBtn","gui_2","buddyListBtn","gui_3","newsBtn","gui_4","awardsBtn","gui_5","book","gui_6","partyBtn","gui_7","money","gui_8","mySettingsBtn","gui_9","reportBtn","gui_10","charWindow","gui_11","swapBtn","gui_12","actionsBtn","gui_13","emotesBtn","gui_14","safeChatBtn","gui_15","chatHistUpDownBtn","gui_16","sendChatBtn","gui_17","denBtn","gui_18","soundBtn","gui_19","worldMapBtn","gui_35","zoneName","gui_36","ansChatBtn","gui_37","chatRepeatBtn","gui_47","playerWall","gui_48","games"];
      
      private static var _guiElementsShop:Array = ["gui_34","reserved for close button callback"];
      
      public function QuestManager()
      {
         super();
      }
      
      public static function get hasJustJoinedQuest() : Boolean
      {
         return _hasJustJoinedQuest;
      }
      
      public static function set hasJustJoinedQuest(param1:Boolean) : void
      {
         _hasJustJoinedQuest = param1;
      }
      
      public static function get questExitPending() : Boolean
      {
         return _questExitPending;
      }
      
      public static function updateCombinedCurrency() : void
      {
         if(_seedInventory)
         {
            _seedInventory.updateCombinedCurrency();
         }
      }
      
      public static function checkQuestOffScreenUsers() : void
      {
         if(_hasJustJoinedQuest)
         {
            _hasJustJoinedQuest = false;
         }
         else
         {
            AvatarManager.updateAvatarOffscreenToMyPosition();
         }
      }
      
      public static function get projectileKeyDown() : Boolean
      {
         return _inQuestRoom && _projectileKeyDown;
      }
      
      public static function getQuestPlayerData(param1:int) : QuestPlayerData
      {
         if(_questPlayersDict[param1] == null && AvatarManager.avatarViewList[param1] != null)
         {
            _questPlayersDict[param1] = new QuestPlayerData();
            _questPlayersDict[param1].init(param1);
         }
         return _questPlayersDict[param1];
      }
      
      public static function initInitialActorStatus(param1:Object, param2:String) : void
      {
         param1.pendingSwfStateName = null;
         param1.onReinitSwfStateName = null;
         param1.spawnedFromActor = param2;
         param1.progress = 0;
         param1.seekType = 0;
         param1.seekTypeSfsId = 0;
         param1.torchEnabled = false;
         param1.iconShowing = false;
         switch(param1.type)
         {
            case 200:
               param1.pickedUp = false;
            case 13:
               param1.status = 0;
               break;
            case 12:
            case 11:
            case 23:
            case 21:
               param1.damageDelay = 0;
               param1.healthPercent = 100;
               param1.respawned = false;
               param1.plantRespawns = false;
         }
      }
      
      public static function loadQuestSfx(param1:int, param2:Function = null) : void
      {
         if(param1 == 3752 || param1 == 3753 || param1 == 5446)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               if(param1 == 3752)
               {
                  param1 = 2698;
               }
               if(param1 == 3753)
               {
                  param1 = 2699;
               }
               if(param1 == 5446)
               {
                  param1 = 5447;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               if(param1 == 3752)
               {
                  param1 = 2730;
               }
               if(param1 == 3753)
               {
                  param1 = 2731;
               }
               if(param1 == 5446)
               {
                  param1 = 5449;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               if(param1 == 3752)
               {
                  param1 = 2755;
               }
               if(param1 == 3753)
               {
                  param1 = 2756;
               }
               if(param1 == 5446)
               {
                  param1 = 5448;
               }
            }
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               if(param1 == 3752)
               {
                  param1 = 2910;
               }
               if(param1 == 3753)
               {
                  param1 = 2911;
               }
               if(param1 == 5446)
               {
                  param1 = 5450;
               }
            }
         }
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,param2 != null ? param2 : onSfxLoaded,true);
      }
      
      private static function onGlobalSfxLoaded(param1:MovieClip) : void
      {
         _globalPackLoaded = true;
         onSfxLoaded(param1);
         if(_soundPacksToLoad)
         {
            while(_soundPacksToLoad.length)
            {
               onSfxLoaded(_soundPacksToLoad.pop());
            }
         }
      }
      
      private static function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc2_:Class = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(_globalPackLoaded)
         {
            _loc3_ = getDefinitionNames(param1.loaderInfo,false,true);
            if(param1.hasOwnProperty("initVolumes"))
            {
               param1.initVolumes();
               _soundMan.setVolumes(param1.volumes);
            }
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length - 1)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc6_ = _loc5_.toLowerCase();
               if(_loc5_ && _loc5_ != "")
               {
                  _loc2_ = param1.loaderInfo.applicationDomain.getDefinition(_loc5_) as Class;
                  _soundMan.addSound(_loc2_,-1,_loc5_);
                  if(_sounds[_loc6_] == null)
                  {
                     _sounds[_loc6_] = _loc2_;
                  }
               }
               _loc4_++;
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
         else
         {
            if(_soundPacksToLoad == null)
            {
               _soundPacksToLoad = [];
            }
            _soundPacksToLoad.push(param1);
         }
      }
      
      public static function playMusic(param1:String, param2:DisplayObject = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(_currentMusic)
         {
            if(_currentMusic != param1)
            {
               if(_currentMusic != "0")
               {
                  if(_SFX_Music[_currentMusic])
                  {
                     _soundMan.fadeOut(_SFX_Music[_currentMusic]);
                     if(param1 != "0")
                     {
                        _playMusicOnLoad = true;
                     }
                  }
               }
               else
               {
                  _loc3_ = 9999;
                  if(param1 == "ajq_phntmprisoner")
                  {
                     _loc3_ = 0;
                  }
                  if(_SFX_Music[param1] == null)
                  {
                     _loc4_ = _streamsLUT[param1];
                     _SFX_Music[param1] = _soundMan.addStream(_loc4_.name,_loc4_.vol);
                  }
                  _soundMan.playStream(_SFX_Music[param1],0,_loc3_,true);
               }
            }
         }
         else if(_sceneLoaded)
         {
            if(_SFX_Music[param1] == null)
            {
               _loc4_ = _streamsLUT[param1];
               _SFX_Music[param1] = _soundMan.addStream(_loc4_.name,_loc4_.vol);
            }
            _soundMan.playStream(_SFX_Music[param1],0,99999);
         }
         else
         {
            _playMusicOnLoad = true;
         }
         _currentMusic = param1;
      }
      
      public static function playSound(param1:String, param2:DisplayObject = null, param3:Boolean = false, param4:String = null) : void
      {
         var _loc8_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:String = param1.toLowerCase();
         if(param2 == null && _streamsLUT[_loc7_])
         {
            if(_SFX_Music[_loc7_] == null)
            {
               _loc8_ = _streamsLUT[_loc7_];
               _SFX_Music[_loc7_] = _soundMan.addStream(_loc8_.name,_loc8_.vol);
            }
            _soundMan.playStream(_SFX_Music[_loc7_]);
         }
         else if(param2 == null || isOnscreen(param2))
         {
            _loc5_ = param2 != null && Boolean(param2.hasOwnProperty("overrideSfxLimit"));
            _loc6_ = int(_sfxTimer[_loc7_] == null ? -1 : _sfxTimer[_loc7_]);
            if(_loc5_ || _loc6_ < 0 || getTimer() - _loc6_ > 500)
            {
               if(param3)
               {
                  if(_currentVOSC)
                  {
                     _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
                     _currentVOSC.stop();
                  }
                  _currentVOActor = param4;
                  _currentVOSC = _soundMan.play(_sounds[_loc7_]);
                  _currentVOSC.addEventListener("soundComplete",voiceOverComplete,false,0,true);
               }
               else
               {
                  _soundMan.play(_sounds[_loc7_],0,0,_loc5_);
               }
               _sfxTimer[_loc7_] = _lastTime;
            }
         }
      }
      
      public static function playLoopingSound(param1:String) : SoundChannel
      {
         return _soundMan.play(_sounds[param1],0,99999);
      }
      
      public static function stopLoopingSound(param1:SoundChannel) : void
      {
         _soundMan.stop(param1);
      }
      
      public static function getAvailableScriptDefs(param1:Function) : Array
      {
         if(_availableScriptDefs == null)
         {
            GenericListXtCommManager.requestGenericList(201,onAvailableScriptsLoaded,param1);
            return null;
         }
         return _availableScriptDefs;
      }
      
      private static function onAvailableScriptsLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _availableScriptDefs = param2;
         if(param3 != null)
         {
            param3();
         }
      }
      
      private static function getStageX(param1:DisplayObject) : Number
      {
         var _loc2_:Number = param1.x;
         var _loc3_:Object = param1;
         while(_loc3_.parent)
         {
            _loc3_ = _loc3_.parent;
            _loc2_ += _loc3_.x;
         }
         return _loc2_;
      }
      
      private static function isOnscreen(param1:DisplayObject) : Boolean
      {
         if(param1.parent == GuiManager.guiLayer)
         {
            return true;
         }
         var _loc2_:Number = param1.x;
         var _loc4_:Number = param1.y;
         var _loc5_:Object = param1;
         while(_loc5_.parent != null && _loc5_.parent != _layerManager.bkg)
         {
            _loc5_ = _loc5_.parent;
            _loc2_ += _loc5_.x;
            _loc4_ += _loc5_.y;
         }
         _loc5_ = AvatarManager.playerAvatarWorldView;
         if(_loc5_ == null)
         {
            return false;
         }
         var _loc6_:Number = Number(_loc5_.x);
         var _loc3_:Number = Number(_loc5_.y);
         while(_loc5_.parent != null && _loc5_.parent != _layerManager.bkg)
         {
            _loc5_ = _loc5_.parent;
            _loc6_ += _loc5_.x;
            _loc3_ += _loc5_.y;
         }
         _loc2_ -= _loc6_;
         _loc4_ -= _loc3_;
         return _loc2_ * _loc2_ + _loc4_ * _loc4_ < 810000;
      }
      
      public static function setSoundLevel(param1:SoundChannel, param2:Number, param3:DisplayObject) : void
      {
         var _loc5_:SoundTransform = null;
         var _loc4_:Number = NaN;
         if(param1 != null)
         {
            if(_maxVolumes[param1] == null)
            {
               _maxVolumes[param1] = param1.soundTransform.volume;
            }
            _loc5_ = param1.soundTransform;
            _loc5_.volume = _maxVolumes[param1] * param2;
            _loc4_ = getStageX(param3);
            _loc5_.pan = Math.min(Math.max(_loc4_ / 450 - 1,-1),1);
            param1.soundTransform = _loc5_;
         }
      }
      
      public static function init(param1:LayerManager) : void
      {
         _layerManager = param1;
         _paused = true;
      }
      
      public static function onStartQuestInit() : void
      {
         _fallingPhantomTimer = 0;
         _lastTime = 0;
         _questExitPending = false;
         _currentMeleeID = 1;
         _questActors = new Vector.<QuestActor>();
         _questActorsDict = new Dictionary();
         _questPlayersDict = new Dictionary();
         _questProjectiles = [];
         _questMelees = [];
         _playerWeaponTimerProjectile = 0;
         _playerWeaponTimerMelee = 0;
         _actorPriority = 0;
         _delayMinigameLaunches = false;
         _delayMinigameID = -1;
         _soundMan = new SoundManager(null,2);
         _sounds = new Dictionary(true);
         _maxVolumes = new Dictionary(true);
         _sfxTimer = new Dictionary(true);
         _SFX_Music = new Dictionary();
         _streamsLUT = new Dictionary();
         _streamsLUT["ajq_musquest"] = {
            "name":"ajq_musQuest",
            "vol":0.4
         };
         _streamsLUT["ajq_musdungeon"] = {
            "name":"ajq_musDungeon",
            "vol":0.64
         };
         _streamsLUT["ajq_muscave"] = {
            "name":"ajq_musCave",
            "vol":0.7
         };
         _streamsLUT["ajq_mustutorial"] = {
            "name":"ajq_musTutorial",
            "vol":0.5
         };
         _streamsLUT["ajq_muscavebossbattle"] = {
            "name":"ajq_musCaveBossBattle",
            "vol":0.55
         };
         _streamsLUT["ajq_musbunnyburrow"] = {
            "name":"ajq_musbunnyBurrow",
            "vol":0.9
         };
         _streamsLUT["ajq_musqueststealth"] = {
            "name":"ajq_musQuestStealth",
            "vol":0.4
         };
         _streamsLUT["musmeetcosmo"] = {
            "name":"MusMeetCosmo",
            "vol":0.36
         };
         _streamsLUT["ajq_musquest_3"] = {
            "name":"ajq_musQuest_3",
            "vol":0.3
         };
         _streamsLUT["ajq_mustreehutplayful"] = {
            "name":"ajq_musTreeHutPlayful",
            "vol":0.38
         };
         _streamsLUT["ajq_muscaveslides"] = {
            "name":"ajq_musCaveSlides",
            "vol":0.23
         };
         _streamsLUT["ajq_mussafelp"] = {
            "name":"ajq_musSafeLP",
            "vol":0.3
         };
         _streamsLUT["ajq_musspooky"] = {
            "name":"ajq_musSpooky",
            "vol":0.44
         };
         _streamsLUT["ajq_phntmprisoner"] = {
            "name":"ajq_phntmPrisoner",
            "vol":0.28
         };
         _streamsLUT["aj_musvolcanogreely"] = {
            "name":"aj_musVolcanoGreely",
            "vol":0.56
         };
         _streamsLUT["aj_musphntmkingintro"] = {
            "name":"aj_musPhntmKingIntro",
            "vol":0.48
         };
         _streamsLUT["ajq_musvolcanofreeze"] = {
            "name":"ajq_musVolcanoFreeze",
            "vol":0.45
         };
         _streamsLUT["ajq_musvolin"] = {
            "name":"ajq_musVolIn",
            "vol":0.35
         };
         _streamsLUT["ajq_musvolout"] = {
            "name":"ajq_musVolOut",
            "vol":0.4
         };
         _streamsLUT["ajq_musphntmkingintro"] = {
            "name":"ajq_musPhntmKingIntro",
            "vol":0.57
         };
         _streamsLUT["ajq_snowyvolerupt"] = {
            "name":"ajq_snowyVolErupt",
            "vol":0.5
         };
         _streamsLUT["aj_musnewjammaintro"] = {
            "name":"aj_musNewJammaIntro",
            "vol":0.47
         };
         _streamsLUT["ajq_musphntmcreepy"] = {
            "name":"ajq_musPhntmCreepy",
            "vol":0.55
         };
         _streamsLUT["ajq_mussearch4greelylp"] = {
            "name":"ajq_musSearch4GreelyLP",
            "vol":0.9
         };
         _streamsLUT["ajq_mus2phntmkings"] = {
            "name":"ajq_mus2PhntmKings",
            "vol":0.7
         };
         _streamsLUT["musquest8"] = {
            "name":"MusQuest8",
            "vol":0.47
         };
         _streamsLUT["ajq_musoceanquest9"] = {
            "name":"ajq_musOceanQuest9",
            "vol":0.55
         };
         _streamsLUT["ajq_musintodeep"] = {
            "name":"ajq_musInToDeep",
            "vol":0.9
         };
         _streamsLUT["ajq_musfactorybosslp"] = {
            "name":"ajq_musFactoryBossLp",
            "vol":0.45
         };
         _streamsLUT["ajq_muscharge"] = {
            "name":"ajq_musCharge",
            "vol":0.8
         };
         _streamsLUT["ajq_musturningthetide"] = {
            "name":"ajq_musTurningTheTide",
            "vol":0.45
         };
         _streamsLUT["ajq_mushauntedforest"] = {
            "name":"ajq_musHauntedForest",
            "vol":0.9
         };
         _streamsLUT["ajq_musgraveyard"] = {
            "name":"ajq_musGraveyard",
            "vol":0.9
         };
         _streamsLUT["ajq_musfroggymarsh"] = {
            "name":"ajq_musFroggyMarsh",
            "vol":0.96
         };
         _streamsLUT["ajq_musouterlimits"] = {
            "name":"ajq_musOuterLimits",
            "vol":1.06
         };
         _streamsLUT["ajq_muspumpkinpatch"] = {
            "name":"ajq_musPumpkinPatch",
            "vol":0.4
         };
         _streamsLUT["ajq_mussciencelab"] = {
            "name":"ajq_musScienceLab",
            "vol":0.2
         };
         _streamsLUT["muscornmaze"] = {
            "name":"MusCornMaze",
            "vol":0.17
         };
         _streamsLUT["ajq_muswinterfun"] = {
            "name":"ajq_musWinterFun",
            "vol":0.35
         };
         _streamsLUT["aj_musnpeintro"] = {
            "name":"aj_musNPEintro",
            "vol":0.4
         };
         _streamsLUT["ajq_musspecialfriends"] = {
            "name":"MusSpecialFriends",
            "vol":0.65
         };
         _streamsLUT["daluckyadv"] = {
            "name":"DALuckyAdv",
            "vol":0.45
         };
         _streamsLUT["musspringfestival"] = {
            "name":"MusSpringFestival",
            "vol":0.6
         };
         _streamsLUT["ajq_mustugofwaridlelp"] = {
            "name":"ajq_musTugOfWarIdleLP",
            "vol":0.4
         };
         _streamsLUT["ajm_tugofwar"] = {
            "name":"ajm_tugOfWar",
            "vol":0.5
         };
         _streamsLUT["ajq_muscraftingvillage"] = {
            "name":"ajq_musCraftingVillage",
            "vol":0.4
         };
         _streamsLUT["ajq_musquest19cave"] = {
            "name":"ajq_musQuest19Cave",
            "vol":0.4
         };
         _streamsLUT["mushiddenfalls"] = {
            "name":"MusHiddenFalls",
            "vol":0.23
         };
         _streamsLUT["ajq_musadvent20hub"] = {
            "name":"ajq_musAdvent20Hub",
            "vol":0.28
         };
         _streamsLUT["ajq_musbattleoftheforrest"] = {
            "name":"ajq_musBattleoftheForrest",
            "vol":0.2
         };
         _streamsLUT["ajq_musintothecaves"] = {
            "name":"ajq_musIntotheCaves",
            "vol":0.6
         };
         _streamsLUT["ajq_mussirgilbertscastle"] = {
            "name":"ajq_musSirGilbertsCastle",
            "vol":0.3
         };
         _streamsLUT["ajq_mustrainingforrest"] = {
            "name":"ajq_musTrainingForrest",
            "vol":0.2
         };
         _streamsLUT["ajq_museeriegreelycave"] = {
            "name":"ajq_musEerieGreelyCave",
            "vol":0.4
         };
         _streamsLUT["ajq_forbodingtheme"] = {
            "name":"ajq_forbodingTheme",
            "vol":0.55
         };
         _streamsLUT["dajamsession"] = {
            "name":"dajamsession",
            "vol":0.5
         };
         _streamsLUT["ajq_musquest22"] = {
            "name":"ajq_musQuest22",
            "vol":0.28
         };
         _streamsLUT["ajq_musquest22b"] = {
            "name":"ajq_musQuest22B",
            "vol":0.28
         };
         _streamsLUT["ajq_musmiratomb"] = {
            "name":"ajq_musMiraTomb",
            "vol":0.24
         };
         _streamsLUT["ajq_mirathemefinal"] = {
            "name":"ajq_MiraThemeFinal",
            "vol":0.55
         };
         _streamsLUT["ajq_musq22finalroom"] = {
            "name":"ajq_musQ22FinalRoom",
            "vol":0.25
         };
         _streamsLUT["ajq_musquest23"] = {
            "name":"ajq_MusQuest23",
            "vol":0.25
         };
         _streamsLUT["ajq_musmadgreely"] = {
            "name":"ajq_musMadGreely",
            "vol":0.35
         };
         _streamsLUT["ajq_musquest23intro"] = {
            "name":"ajq_MusQuest23Intro",
            "vol":0.25
         };
         _streamsLUT["ajq_musphntmretreat"] = {
            "name":"ajq_musPhntmRetreat",
            "vol":0.35
         };
         _streamsLUT["musnewyearsfortune"] = {
            "name":"MusNewYearsFortune",
            "vol":0.2
         };
         _streamsLUT["ajq_musphntmdiguise"] = {
            "name":"ajq_musPhntmDiguise",
            "vol":0.2
         };
         _streamsLUT["ajq_muscombat"] = {
            "name":"ajq_musCombat",
            "vol":0.33
         };
         _streamsLUT["ajq_muspeckssecret"] = {
            "name":"ajq_musPecksSecret",
            "vol":0.2
         };
         _streamsLUT["ajq_musphntminvasion"] = {
            "name":"ajq_musPhntmInvasion",
            "vol":0.24
         };
         _streamsLUT["ajq_musrooftop"] = {
            "name":"ajq_musRoofTop",
            "vol":0.32
         };
         _streamsLUT["ajq_mussuspicious"] = {
            "name":"ajq_musSuspicious",
            "vol":0.27
         };
         _streamsLUT["ajq_muspecksafe"] = {
            "name":"ajq_musPeckSafe",
            "vol":0.34
         };
         _streamsLUT["ajm_musbossbattle25"] = {
            "name":"ajm_musBossBattle25",
            "vol":0.39
         };
         _streamsLUT["ajq_musmine"] = {
            "name":"ajq_musMine",
            "vol":0.65
         };
         _streamsLUT["ajq_mustikitrouble"] = {
            "name":"ajq_musTikiTrouble",
            "vol":0.25
         };
         _streamsLUT["ajq_musinsidetemple"] = {
            "name":"ajq_musInsideTemple",
            "vol":0.5
         };
         _streamsLUT["ajq_muspatience"] = {
            "name":"ajq_musPatience",
            "vol":0.43
         };
         _streamsLUT["ajq_musquest27intro"] = {
            "name":"ajq_musQuest27Intro",
            "vol":0.35
         };
         _streamsLUT["ajq_mustrialscomplete"] = {
            "name":"ajq_musTrialsComplete",
            "vol":0.25
         };
         _streamsLUT["ajq_mustricksters"] = {
            "name":"ajq_musTricksters",
            "vol":0.45
         };
         _streamsLUT["ajq_muswaywilds"] = {
            "name":"ajq_musWayWilds",
            "vol":0.3
         };
         _streamsLUT["ajq_muswisdom"] = {
            "name":"ajq_musWisdom",
            "vol":0.25
         };
         _streamsLUT["ajq_heartstonesong"] = {
            "name":"ajq_HeartStoneSong",
            "vol":0.28
         };
         _streamsLUT["ajq_muslostcity"] = {
            "name":"ajq_musLostCity",
            "vol":0.43
         };
         _streamsLUT["ajq_muslostcitytheme"] = {
            "name":"ajq_musLostCityTheme",
            "vol":0.75
         };
         _streamsLUT["ajq_muslcbattle"] = {
            "name":"ajq_musLCBattle",
            "vol":0.43
         };
         _streamsLUT["musalphasroom"] = {
            "name":"MusAlphasRoom",
            "vol":0.25
         };
         _streamsLUT["ajq_mus29battle"] = {
            "name":"ajq_mus29Battle",
            "vol":0.6
         };
         _streamsLUT["ajq_musq29intro"] = {
            "name":"ajq_musQ29Intro",
            "vol":0.25
         };
         _streamsLUT["ajq_musq29end"] = {
            "name":"ajq_musQ29End",
            "vol":0.25
         };
         _assetPool = new Dictionary();
         _playerLeftObjects = [{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         },{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         },{
            "icon":GETDEFINITIONBYNAME("leaveAdvTxt"),
            "hasLeft":false,
            "complete":false
         }];
         gMainFrame.stage.addEventListener("keyUp",keyHandleUp);
         gMainFrame.stage.addEventListener("keyDown",keyHandleDown);
         gMainFrame.stage.addEventListener("QuestEventLoadSfx",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventPlaySfx",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventTorch",onQuestEvent,false,0,true);
         gMainFrame.stage.addEventListener("QuestEventTriggerCameraShake",onQuestEvent,false,0,true);
         _roomManager = RoomManagerWorld.instance;
      }
      
      public static function destroy(param1:Boolean = false) : void
      {
         gMainFrame.stage.removeEventListener("keyUp",keyHandleUp);
         gMainFrame.stage.removeEventListener("keyDown",keyHandleDown);
         gMainFrame.stage.removeEventListener("QuestEventLoadSfx",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventPlaySfx",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventTorch",onQuestEvent);
         gMainFrame.stage.removeEventListener("QuestEventTriggerCameraShake",onQuestEvent);
         _paused = true;
         _questActors = null;
         _questActorsDict = null;
         _questPlayersDict = null;
         _questProjectiles = null;
         _questMelees = null;
         _soundMan = null;
         _sounds = null;
         _maxVolumes = null;
         _sfxTimer = null;
         _SFX_Music = null;
         _streamsLUT = null;
         _assetPool = null;
         _playerLeftObjects = null;
         _roomManager = null;
         _questActorDictionary = null;
         clearPlayerDictionary();
         if(!param1)
         {
            onExitRoom("destroy");
         }
         _questExitPending = false;
      }
      
      private static function onQuestEvent(param1:QuestEvent) : void
      {
         var _loc2_:int = 0;
         if(_questActorDictionary != null)
         {
            switch(param1.type)
            {
               case "QuestEventLoadSfx":
                  _loc2_ = int(param1.secondaryType);
                  if(_loc2_ > 0)
                  {
                     loadQuestSfx(int(param1.secondaryType));
                  }
                  break;
               case "QuestEventPlaySfx":
                  playSound(param1.secondaryType,param1.target as DisplayObject);
                  break;
               case "QuestEventTorch":
                  if(param1.secondaryType == "on")
                  {
                     addTorch(param1.target);
                     break;
                  }
                  removeTorch(param1.target);
                  break;
               case "QuestEventTriggerCameraShake":
                  _shaketimer = 0.5;
            }
         }
      }
      
      public static function actorCollisionTest(param1:String, param2:Boolean = false) : Boolean
      {
         var _loc3_:QuestActor = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc4_:int = 0;
         var _loc7_:QuestActor = _questActorsDict[param1];
         if(_loc7_)
         {
            _loc5_ = _loc7_.actorOffset;
            _loc5_.x = _loc5_.x + _loc7_.x;
            _loc5_.y += _loc7_.y;
            _loc6_ = new Point(AvatarManager.playerAvatarWorldView.x + -15,AvatarManager.playerAvatarWorldView.y + -40);
            if(Collision.circleHitCircle(_loc5_,_loc7_.collisionRadiusMoving,_loc6_,50))
            {
               return true;
            }
            if(param2)
            {
               return false;
            }
            _loc4_ = 0;
            while(_loc4_ < _questActors.length)
            {
               _loc3_ = _questActors[_loc4_];
               if(!_loc3_.getIsDead() && !_loc3_.isDying && _loc3_.priority > _loc7_.priority && _loc3_._actorData.type == 11)
               {
                  _loc6_ = _loc3_.actorOffset;
                  _loc6_.x = _loc6_.x + _loc3_.x;
                  _loc6_.y += _loc3_.y;
                  if(Collision.circleHitCircle(_loc5_,_loc7_.collisionRadiusMoving,_loc6_,_loc3_.collisionRadiusMoving))
                  {
                     return true;
                  }
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public static function mouseHandleDown(param1:MouseEvent) : Boolean
      {
         var _loc4_:Point = null;
         var _loc3_:QuestActor = null;
         var _loc2_:int = 0;
         if(_roomManager)
         {
            _loc4_ = _roomManager.convertScreenToWorldSpace(param1.stageX,param1.stageY);
            if(projectileKeyDown)
            {
               playerLaunchWeapon(_loc4_,true);
               if(AvatarManager.playerAvatarWorldView && AvatarManager.playerAvatarWorldView.moving)
               {
                  _roomManager.forceStopMovement();
               }
               AvatarManager.playerAvatarWorldView.faceAnim(_loc4_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc4_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
               return true;
            }
            if(_questActors)
            {
               _loc2_ = 0;
               while(_loc2_ < _questActors.length)
               {
                  _loc3_ = _questActors[_loc2_];
                  if((_loc3_._attackable == 1 || _loc3_._attackable == 3) && _loc3_.handleMouseDown(_loc4_))
                  {
                     AvatarManager.playerAvatarWorldView.faceAnim(_loc4_.x - AvatarManager.playerAvatarWorldView.avatarPos.x,_loc4_.y - AvatarManager.playerAvatarWorldView.avatarPos.y,false);
                     return true;
                  }
                  _loc2_++;
               }
            }
         }
         return false;
      }
      
      private static function voiceOverComplete(param1:Event) : void
      {
         if(_questActorDictionary != null)
         {
            if(_currentVOSC != null)
            {
               _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
            }
            if(_currentVOActor != null && _questActorDictionary["ffm_party"] == null)
            {
               QuestXtCommManager.questActorTriggered(_currentVOActor);
               _currentVOActor = null;
            }
         }
      }
      
      private static function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 16)
         {
            case 0:
               _projectileKeyDown = false;
         }
      }
      
      private static function keyHandleDown(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
         loop1:
         switch(int(param1.keyCode) - 16)
         {
            case 0:
               break;
            case 16:
               if(isSideScrollQuest())
               {
                  if(_talkingPopup != null)
                  {
                     onOkBtn(null);
                     break;
                  }
                  _loc2_ = 0;
                  while(true)
                  {
                     if(_loc2_ >= _questActors.length)
                     {
                        break loop1;
                     }
                     _questActors[_loc2_].handleKeyDown(param1.keyCode);
                     _loc2_++;
                  }
               }
         }
      }
      
      public static function muteChanged(param1:Boolean) : void
      {
         var _loc3_:QuestActor = null;
         var _loc2_:int = 0;
         if(_questActors)
         {
            _loc2_ = 0;
            while(_loc2_ < _questActors.length)
            {
               _loc3_ = _questActors[_loc2_];
               if(_loc3_.alertLP)
               {
                  stopLoopingSound(_loc3_.alertLP);
                  _loc3_.alertLP = null;
               }
               _loc2_++;
            }
         }
      }
      
      public static function onExitRoom(param1:String = "") : void
      {
         var _loc5_:int = 0;
         var _loc4_:AvatarInfo = null;
         var _loc2_:int = 0;
         var _loc6_:AvatarEditor = null;
         var _loc8_:Object = null;
         var _loc7_:Object = null;
         var _loc3_:int = 0;
         var _loc9_:Object = null;
         if(_questExitPending)
         {
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(_loc4_)
            {
               _loc4_.questTorchStatus = false;
            }
            if(_playSwfMC != null)
            {
               if(_playSwfMC.parent != null)
               {
                  _playSwfMC.parent.removeChild(_playSwfMC);
               }
               _playSwfMC = null;
               UserCommXtCommManager.sendPermEmote(-1);
            }
            if(_guiElementsSkipBtnMh)
            {
               _guiElementsSkipBtnMh.destroy();
               _guiElementsSkipBtnMh = null;
            }
            if(_guiElementsSkipBtn)
            {
               _guiElementsSkipBtn.removeEventListener("mouseDown",guiElementsSkipBtnPress);
               if(_guiElementsSkipBtn.parent)
               {
                  _guiElementsSkipBtn.parent.removeChild(_guiElementsSkipBtn);
               }
               _guiElementsSkipBtn.visible = false;
               _guiElementsSkipBtn = null;
            }
            _loc2_ = 0;
            while(_loc2_ < _guiElementsGuiManager.length)
            {
               if(GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]])
               {
                  if(GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].hasOwnProperty("setButtonState"))
                  {
                     GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].setButtonState(1);
                  }
                  GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].removeEventListener("mouseDown",guiDownHandler);
                  GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].removeEventListener("mouseOver",guiDownHandler);
               }
               _loc2_ += 2;
            }
            GuiManager.grayHudAvatar(false);
            if(GuiManager.mainHud.emailChatBtn)
            {
               GuiManager.mainHud.emailChatBtn.activateGrayState(false);
            }
            _loc6_ = GuiManager.avatarEditor;
            if(_loc6_ != null)
            {
               _loc2_ = 0;
               while(_loc2_ < _guiElementsAvatarEditor.length)
               {
                  _loc8_ = _loc6_.avEditor[_guiElementsAvatarEditor[_loc2_ + 1]];
                  if(_loc8_ == null)
                  {
                     _loc8_ = _loc6_[_guiElementsAvatarEditor[_loc2_ + 1]];
                  }
                  if(_loc8_)
                  {
                     if(_loc8_.hasOwnProperty("setButtonState"))
                     {
                        _loc8_.setButtonState(1);
                     }
                     _loc8_.removeEventListener("mouseDown",avEdDownHandler);
                  }
                  _loc2_ += 2;
               }
            }
            _questPlayersSwitched = null;
            _questScriptDefId = 0;
            AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
            _inQuestRoom = false;
            gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId).questHealthPercentage = 100;
            _layerManager.bkg.scaleY = 1;
            _layerManager.bkg.scaleX = 1;
            _questActorDictionary = null;
            gMainFrame.stage.removeEventListener("mouseDown",resetMouseDownIdleTimer);
            gMainFrame.stage.removeEventListener("mouseMove",resetMouseMoveIdleTimer);
            if(_kickPopup != null)
            {
               _kickPopup.destroy();
               _kickPopup = null;
            }
            if(_progressingSC)
            {
               _progressingSC.stop();
            }
            if(_progressingSCnot)
            {
               _progressingSCnot.stop();
            }
            for(_loc9_ in _assetPool)
            {
               delete _assetPool[_loc9_];
            }
            _loc5_ = 0;
            while(_loc5_ < _playerLeftObjects.length)
            {
               _loc7_ = _playerLeftObjects[_loc5_];
               if(_loc7_ && _loc7_.icon.parent && _loc7_.icon.parent == GuiManager.guiLayer)
               {
                  GuiManager.guiLayer.removeChild(_loc7_.icon);
               }
               _loc7_.hasLeft = false;
               _loc7_.complete = false;
               _loc5_++;
            }
            _roomManager.setGridDepth(128);
            if(_currentMusic && _SFX_Music[_currentMusic])
            {
               _SFX_Music[_currentMusic].stop();
            }
            if(_currentAmbient && _SFX_AmbientSC)
            {
               _SFX_AmbientSC.stop();
            }
            _currentMusic = _currentAmbient = null;
            _playMusicOnLoad = false;
            if(_seedInventory)
            {
               _seedInventory.destroy();
               _seedInventory = null;
            }
            _roomManager.removeAndClearMiniMap();
            if(_fader)
            {
               if(_fader.parent)
               {
                  _fader.parent.removeChild(_fader);
               }
               _fader = null;
            }
            _queueFadeIn = false;
         }
         _delayMinigameLaunches = false;
         _delayMinigameID = -1;
         if(_soundMan)
         {
            _soundMan.destroy(_questExitPending);
         }
         if(_questExitPending)
         {
            _sounds = new Dictionary(true);
            _maxVolumes = new Dictionary(true);
            _sfxTimer = new Dictionary(true);
            _SFX_Music = new Dictionary();
            _globalPackLoaded = false;
         }
         if(_adventureTimer && _adventureTimer.parent)
         {
            _adventureTimer.parent.removeChild(_adventureTimer);
            _adventureTimer = null;
         }
         if(_adventureHotCold && _adventureHotCold.parent)
         {
            _adventureHotCold.parent.removeChild(_adventureHotCold);
            _adventureHotCold = null;
         }
         if(_adventureGoals)
         {
            _loc3_ = 1;
            while(_loc3_ <= 5)
            {
               if(_adventureGoals[_loc3_] && _adventureGoals[_loc3_].parent)
               {
                  _adventureGoals[_loc3_].parent.removeChild(_adventureGoals[_loc3_]);
                  _adventureGoals[_loc3_] = null;
               }
               _loc3_++;
            }
            _adventureGoals = null;
         }
         if(_playSwfMCSC)
         {
            _playSwfMCSC.stop();
            _playSwfMCSC = null;
         }
         if(_currentVOSC)
         {
            _currentVOSC.removeEventListener("soundComplete",voiceOverComplete);
            _currentVOSC.stop();
            _currentVOSC = null;
            _currentVOActor = null;
         }
         if(_fader && _fader.parent)
         {
            _fader.parent.removeChild(_fader);
            _fader = null;
         }
         if(_darknessMask)
         {
            removeDarkness();
         }
         if(_questProjectiles)
         {
            _loc5_ = 0;
            while(_loc5_ < _questProjectiles.length)
            {
               _questProjectiles[_loc5_].destroy();
               _loc5_++;
            }
            _questProjectiles.splice(0,_questProjectiles.length);
         }
         if(_questMelees)
         {
            _loc5_ = 0;
            while(_loc5_ < _questMelees.length)
            {
               _questMelees[_loc5_].destroy();
               _loc5_++;
            }
            _questMelees.splice(0,_questMelees.length);
         }
         if(_questActors)
         {
            _loc5_ = 0;
            while(_loc5_ < _questActors.length)
            {
               _questActors[_loc5_].destroy();
               _loc5_++;
            }
            _questActors = new Vector.<QuestActor>();
            _questActorsDict = new Dictionary();
         }
         if(_questPlayersDict)
         {
            for(_loc9_ in _questPlayersDict)
            {
               _questPlayersDict[_loc9_].destroy();
               delete _questPlayersDict[_loc9_];
            }
         }
         if(_fallingPhantoms.length > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _fallingPhantoms.length)
            {
               _loc9_ = _fallingPhantoms[_loc5_];
               if(_loc9_ != null)
               {
                  if(_loc9_.mh != null)
                  {
                     _loc9_.mh.destroy();
                     _loc9_.mh = null;
                  }
                  if(_loc9_.theSprite != null && _loc9_.theSprite.parent != null)
                  {
                     _loc9_.theSprite.parent.removeChild(_loc9_.theSprite);
                     _loc9_.theSprite = null;
                     _loc9_.npc = null;
                  }
               }
               _loc5_++;
            }
            _fallingPhantoms.splice(0,_fallingPhantoms.length);
         }
         _fallingPhantomVolumeActors = null;
         if(_talkingLoadingSpiral)
         {
            _talkingLoadingSpiral.destroy();
            _talkingLoadingSpiral = null;
         }
         _talkingPopup = null;
         _paused = true;
         _sceneLoaded = false;
         if(_questExitPending && param1 != "destroy")
         {
            destroy(true);
         }
         _questExitPending = false;
      }
      
      public static function getNearestPlant(param1:Number, param2:Number, param3:Number, param4:int) : QuestActor
      {
         var _loc13_:QuestActor = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc12_:Point = null;
         var _loc6_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:* = -1;
         var _loc5_:* = null;
         param3 *= param3;
         _loc7_ = 0;
         while(_loc7_ < _questActors.length)
         {
            _loc13_ = _questActors[_loc7_];
            if(_loc13_._visible && _loc13_._actorData.type == 21 && _loc13_.plantTargettable())
            {
               _loc8_ = _loc13_.npcDef;
               if(_loc8_ != null && _loc8_.level <= param4)
               {
                  _loc12_ = _loc13_.actorOffset;
                  _loc6_ = param1 - (_loc13_._actorData.actorPos.x + _loc12_.x);
                  _loc11_ = param2 - (_loc13_._actorData.actorPos.y + _loc12_.y);
                  _loc9_ = _loc6_ * _loc6_ + _loc11_ * _loc11_;
                  if(_loc9_ < param3 && (_loc10_ == -1 || _loc9_ < _loc10_))
                  {
                     _loc5_ = _loc13_;
                     _loc10_ = _loc9_;
                  }
               }
            }
            _loc7_++;
         }
         return _loc5_;
      }
      
      public static function getNearestActivePhantom(param1:Number, param2:Number, param3:Number, param4:int, param5:Boolean, param6:Boolean, param7:Boolean) : Array
      {
         var _loc13_:Array = null;
         var _loc12_:* = NaN;
         var _loc16_:QuestActor = null;
         var _loc9_:int = 0;
         var _loc10_:Object = null;
         var _loc17_:Point = null;
         var _loc8_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc11_:Number = NaN;
         param3 *= param3;
         _loc9_ = 0;
         while(_loc9_ < _questActors.length)
         {
            _loc16_ = _questActors[_loc9_];
            if(_loc16_._visible && !_loc16_.getIsDead())
            {
               if(_loc16_._actorData.type == 11 && (param5 || _loc16_._seekActive != 0) || param6 && (_loc16_._actorData.type == 23 || _loc16_._actorData.type == 12))
               {
                  _loc10_ = _loc16_.npcDef;
                  if(param7 && _loc10_ != null && _loc10_.level <= param4 && _loc16_.isVulnerable())
                  {
                     _loc17_ = _loc16_.actorOffset;
                     _loc8_ = param1 - (_loc16_.x + _loc17_.x);
                     _loc15_ = param2 - (_loc16_.y + _loc17_.y);
                     _loc11_ = _loc8_ * _loc8_ + _loc15_ * _loc15_;
                     if(_loc11_ < param3)
                     {
                        if(_loc13_ == null)
                        {
                           _loc13_ = [];
                           _loc12_ = _loc11_;
                           _loc13_.push(_loc16_);
                        }
                        else if(_loc11_ < _loc12_)
                        {
                           _loc12_ = _loc11_;
                           _loc13_.unshift(_loc16_);
                        }
                        else
                        {
                           _loc13_.push(_loc16_);
                        }
                     }
                  }
               }
            }
            _loc9_++;
         }
         return _loc13_;
      }
      
      public static function createDarkness() : void
      {
         if(_darknessMask)
         {
            throw new Error("Error creating darkness! Darkness is already created!");
         }
         _darknessMask = new Sprite();
         _darknessMask.blendMode = "layer";
         _darknessMask.mouseEnabled = false;
         _darknessMask.mouseChildren = false;
         var _loc1_:Sprite = new Sprite();
         _loc1_.graphics.beginFill(0);
         _loc1_.graphics.drawRect(0,0,900,550);
         _loc1_.graphics.endFill();
         _darknessMask.addChild(_loc1_);
         _layerManager.bkg.addChild(_darknessMask);
      }
      
      public static function removeDarkness() : void
      {
         if(_darknessMask)
         {
            if(_darknessMask.parent)
            {
               _darknessMask.parent.removeChild(_darknessMask);
            }
            _darknessMask = null;
            _torches = null;
            trace("removing darkness");
         }
      }
      
      public static function addTorch(param1:Object, param2:Number = 1, param3:int = 0, param4:int = 0) : MovieClip
      {
         var _loc7_:Object = null;
         var _loc6_:Boolean = false;
         if(!_sceneLoaded)
         {
            _addTorchQueue.push({
               "actor":param1,
               "scale":param2,
               "offsetX":param3,
               "offsetY":param4
            });
            return null;
         }
         if(_darknessMask == null)
         {
            _loc6_ = createDarknessFromScene();
            if(!_loc6_)
            {
               _actorLightQueue.push(param1);
               return null;
            }
            for each(_loc7_ in _actorLightQueue)
            {
               addTorch(_loc7_);
            }
            _actorLightQueue = [];
         }
         if(_torches)
         {
            for each(_loc7_ in _torches)
            {
               if(_loc7_.actor == param1)
               {
                  if(_loc7_.actor == AvatarManager.playerAvatarWorldView)
                  {
                     _loc7_.light.scaleX = _loc7_.light.scaleY = param2;
                  }
                  return null;
               }
            }
         }
         else
         {
            _torches = [];
         }
         _loc7_ = {};
         var _loc5_:Object = null;
         if(param1.hasOwnProperty("_torch"))
         {
            _loc5_ = param1._torch;
            _loc5_.x = _loc5_.x + _loc5_.width / 2;
            _loc5_.y += _loc5_.height / 2;
            param1 = param1.parent;
         }
         else if(param1.hasOwnProperty("torch"))
         {
            _loc5_ = param1.torch;
            if(param1.parent == _layerManager.room_chat)
            {
               _loc7_.layer = 1;
               _loc5_.x = 650;
               _loc5_.y = 470;
            }
            else
            {
               param1 = param1.parent;
               _loc7_.layer = 1;
               _loc5_.x = 320;
               _loc5_.y = 180;
            }
         }
         else if(param1.hasOwnProperty("s") && param1.s.content.hasOwnProperty("torch"))
         {
            _loc5_ = param1.s.content.torch;
            _loc7_.layer = 0;
         }
         if(_loc5_)
         {
            _loc7_.light = _loc5_;
            _loc7_.light.visible = true;
            _loc7_.offsetX = _loc7_.light.x;
            _loc7_.offsetY = _loc7_.light.y;
         }
         else
         {
            _loc7_.light = new torch();
            _loc7_.light.scaleX = _loc7_.light.scaleY = param2;
            _loc7_.offsetX = param3;
            _loc7_.offsetY = param4;
            _loc7_.layer = 1;
         }
         _darknessMask.addChild(_loc7_.light);
         _loc7_.light.blendMode = "erase";
         _loc7_.actor = param1;
         _torches.push(_loc7_);
         return _loc7_.light;
      }
      
      public static function createDarknessFromScene() : Boolean
      {
         var _loc4_:* = null;
         var _loc2_:Sprite = null;
         var _loc3_:int = 0;
         var _loc5_:DisplayObject = null;
         if(!_sceneLoaded)
         {
            trace("das not good");
         }
         var _loc1_:Array = _roomManager.getDarknessFromScene();
         trace("adding darkness");
         if(_loc1_.length > 0)
         {
            trace("found darkness");
            _darknessMask = new Sprite();
            _darknessMask.blendMode = "layer";
            _darknessMask.mouseEnabled = false;
            _darknessMask.mouseChildren = false;
            for each(_loc4_ in _loc1_)
            {
               _darknessMask.addChild(_loc4_);
            }
            _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
            _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            _loc2_ = _layerManager.room_fg;
            if(_loc2_.numChildren > 0)
            {
               _loc3_ = _loc2_.numChildren - 1;
               while(_loc3_ >= 0)
               {
                  _loc5_ = _loc2_.getChildAt(_loc3_);
                  if(!_loc5_.hasOwnProperty("eye") && !_loc5_.hasOwnProperty("watcher"))
                  {
                     break;
                  }
                  _loc3_--;
               }
               _loc2_.addChildAt(_darknessMask,_loc3_ >= 0 ? _loc3_ : 0);
            }
            else
            {
               _loc2_.addChild(_darknessMask);
            }
         }
         return _loc1_.length > 0;
      }
      
      public static function removeTorch(param1:Object) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(_torches != null)
         {
            _loc2_ = 0;
            for each(_loc3_ in _torches)
            {
               if(_loc3_.actor == param1)
               {
                  if(param1 == AvatarManager.playerAvatarWorldView)
                  {
                     _loc3_.light.scaleY = 0.7;
                     _loc3_.light.scaleX = 0.7;
                     break;
                  }
                  _loc3_.light.parent.removeChild(_loc3_.light);
                  _torches.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public static function heartbeat(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc5_:AvatarWorldView = null;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc13_:Object = null;
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc16_:int = 0;
         var _loc7_:* = null;
         var _loc4_:int = 0;
         var _loc14_:QuestActor = null;
         if(!_paused)
         {
            _frameTime = (param1 - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = param1;
            if(_handlePickGiftDelayTimer > 0)
            {
               if(_handlePickGiftDelayData != null)
               {
                  _handlePickGiftDelayTimer -= _frameTime;
                  if(_handlePickGiftDelayTimer <= 0)
                  {
                     handlePickGift(_handlePickGiftDelayData,true);
                     _handlePickGiftDelayData = null;
                  }
               }
               else
               {
                  _handlePickGiftDelayTimer = 0;
               }
            }
            if(_shaketimer > 0)
            {
               _shaketimer -= _frameTime;
               if(_shaketimer > 0)
               {
                  if(_shakeOrigPos != null)
                  {
                     shake();
                  }
                  else
                  {
                     startShake();
                  }
               }
               else
               {
                  _shaketimer = 0;
                  stopShake();
               }
            }
            if(_playSwfMC != null)
            {
               if(_playSwfMC.bFinished)
               {
                  if(_faderState < 3)
                  {
                     _faderState = 3;
                  }
               }
               else
               {
                  if(_faderState > 0)
                  {
                     _roomManager.forceStopMovement();
                  }
                  if(_faderState >= 2)
                  {
                     _playSwfMCTimeElapsed += _frameTime;
                     _loc2_ = _playSwfMCTimeElapsed * 24;
                     if(_loc2_ >= _playSwfMC.totalFrames)
                     {
                        _loc2_ = _playSwfMC.totalFrames;
                     }
                     _playSwfMC.gotoAndStop(_loc2_);
                  }
               }
            }
            if(_fader && _fader.parent)
            {
               if(_faderState == 0 || _faderState == 3)
               {
                  _fader.alpha += _frameTime * 1;
                  if(_fader.alpha >= 1)
                  {
                     _fader.alpha = 1;
                     _faderState++;
                     if(_faderState == 4)
                     {
                        QuestXtCommManager.sendPlaySwfComplete();
                        if(_playSwfMC.parent != null)
                        {
                           _playSwfMC.parent.removeChild(_playSwfMC);
                        }
                        _playSwfMC = null;
                        UserCommXtCommManager.sendPermEmote(-1);
                     }
                  }
               }
               else if(_playSwfMC || _faderState == 4)
               {
                  if(_faderState == 1)
                  {
                     _faderState = 2;
                     playSwf();
                  }
                  if(_frameTime < 0.5)
                  {
                     _fader.alpha -= _frameTime * 1;
                     if(_fader.alpha <= 0)
                     {
                        _fader.alpha = 0;
                        if(_faderState == 4)
                        {
                           _fader.parent.removeChild(_fader);
                           _fader = null;
                        }
                     }
                  }
               }
            }
            _loc5_ = AvatarManager.playerAvatarWorldView;
            if(_questActorDictionary != null)
            {
               if(AvatarManager.playerAvatarWorldView)
               {
                  _roomManager.updatePlayerPos(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
               }
               _gameIdleTimer += _frameTime;
               if(_gameIdleTimer > 240)
               {
                  if((gMainFrame.userInfo.isModerator || gMainFrame.clientInfo.accountType == 4) && !gMainFrame.server.isBlueboxMode())
                  {
                     KeepAlive.sendKeepAliveReset();
                     _gameIdleTimer = 0;
                  }
                  else if(_gameIdleTimer > 300)
                  {
                     _gameIdleTimer = 0;
                     commandExit();
                  }
                  else if(_kickPopup == null)
                  {
                     _kickPopup = new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14681),true,onKickWarningPopup);
                     AJAudio.playIdleWarningSound();
                  }
               }
               if(_fallingPhantomVolumeActors != null)
               {
                  updateFallingPhantoms();
               }
               for each(var _loc18_ in _questPlayersDict)
               {
                  if(_loc18_ != null)
                  {
                     _loc18_.heartbeat();
                  }
               }
               if(_guiTimerLocal > 0)
               {
                  _loc6_ = int(_guiTimerLocal) % 60;
                  _guiTimerLocal -= _frameTime;
                  _loc9_ = int(_guiTimerLocal) % 60;
                  if(_loc6_ > _loc9_)
                  {
                     _soundMan.play(_sounds["aj_play_timer_tick1"]);
                  }
                  if(_adventureTimer)
                  {
                     _adventureTimer.time = _guiTimerLocal;
                     _loc3_ = _adventureTimer.time / 60;
                     _loc9_ = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = _loc3_;
                     _adventureTimer.clock.clockText_2.text = (_loc9_ >= 10 ? "" : "0") + _loc9_;
                     if(_adventureTimer.time < 60 && _adventureTimer.time + _frameTime > 60)
                     {
                        _adventureTimer.startPulse();
                     }
                  }
                  if(_guiTimerLocal <= 0)
                  {
                     QuestXtCommManager.questActorTriggered("gui_time_min");
                     _adventureTimer.visible = false;
                     _guiTimerLocal = 0;
                  }
               }
               _loc13_ = _questActorDictionary["gui_timer"];
               if(_loc13_ != null)
               {
                  if(_adventureTimer)
                  {
                     _adventureTimer.time = _loc13_.state;
                     _loc10_ = _adventureTimer.time / 60;
                     _loc8_ = int(_adventureTimer.time) % 60;
                     _adventureTimer.clock.clockText_1.text = _loc10_;
                     _adventureTimer.clock.clockText_2.text = (_loc8_ >= 10 ? "" : "0") + _loc8_;
                     if(_adventureTimer.time < 60 && _adventureTimer.time + _frameTime > 60)
                     {
                        _adventureTimer.startPulse();
                     }
                  }
               }
               if(_adventureGoals != null)
               {
                  loop7:
                  switch((_loc15_ = getAdventureType()) - 1)
                  {
                     case 0:
                     case 2:
                     case 3:
                     case 4:
                     case 5:
                     case 6:
                     case 7:
                     case 8:
                        if(_questActorDictionary["gui_goal1"])
                        {
                           if(_adventureGoals[1])
                           {
                              _loc17_ = getMaxQuestGoal(_loc15_);
                              _loc16_ = 0;
                              _loc11_ = 1;
                              while(_loc11_ <= _loc17_)
                              {
                                 _loc12_ = "gui_goal" + _loc11_ + "a";
                                 if(_loc11_ == _loc17_ || _questActorDictionary[_loc12_] != null && _questActorDictionary[_loc12_].state > _playerOrbCountTotal)
                                 {
                                    switch(_loc15_ - 5)
                                    {
                                       case 0:
                                          _loc16_ = _questActorDictionary[_loc12_].state + 1;
                                          break;
                                       default:
                                          _loc16_ = int(_questActorDictionary[_loc12_].state);
                                    }
                                    _adventureGoals[1].setMaxValue(_loc16_);
                                    break;
                                 }
                                 _loc11_++;
                              }
                              switch(_loc15_ - 4)
                              {
                                 case 0:
                                 case 1:
                                    _adventureGoals[1].setValue(_loc16_ - _playerCrystalCount);
                                    break loop7;
                                 case 3:
                                    _adventureGoals[1].setValue(Math.min(_playerCrystalCount,_loc16_));
                                    break loop7;
                                 default:
                                    _adventureGoals[1].setValue(_playerCrystalCount);
                              }
                           }
                        }
                        break;
                     default:
                        if(_questActorDictionary["showorbcount"] != null)
                        {
                           if(_adventureGoals[1])
                           {
                              _adventureGoals[1].setValue(_playerCrystalCount);
                           }
                           break;
                        }
                        _loc11_ = 1;
                        while(true)
                        {
                           if(_loc11_ > 5)
                           {
                              break loop7;
                           }
                           _loc12_ = "gui_goal" + _loc11_;
                           if(!_questActorDictionary[_loc12_])
                           {
                              break loop7;
                           }
                           if(_adventureGoals[_loc11_])
                           {
                              _adventureGoals[_loc11_].setValue(_questActorDictionary[_loc12_].state);
                           }
                           _loc11_++;
                        }
                        break;
                  }
               }
            }
            for each(_loc7_ in _torches)
            {
               if(_loc7_.actor != null)
               {
                  _loc7_.light.x = _loc7_.actor.x + _loc7_.offsetX;
                  _loc7_.light.y = _loc7_.actor.y + _loc7_.offsetY;
                  if(_loc7_.layer == 0)
                  {
                     _loc7_.light.x -= _layerManager.room_avatars.x;
                     _loc7_.light.y -= _layerManager.room_avatars.y;
                  }
                  else
                  {
                     _loc7_.light.x -= _loc7_.light.width * 0.5;
                     _loc7_.light.y -= _loc7_.light.height * 0.5;
                  }
               }
            }
            if(_darknessMask)
            {
               _darknessMask.x = _layerManager.room_avatars.x + _layerManager.room_bkg_group.x;
               _darknessMask.y = _layerManager.room_avatars.y + _layerManager.room_bkg_group.y;
            }
            if(_defeatedPopUpTimer > 0)
            {
               _roomManager.forceStopMovement();
               _defeatedPopUpTimer -= _frameTime;
               if(_defeatedPopUpTimer <= 0)
               {
                  new SBParchmentPopup(GuiManager.guiLayer,3,LocalizationManager.translateIdOnly(14811),true,onDeathAccept);
               }
            }
            if(_playerWeaponTimerProjectile > 0)
            {
               _playerWeaponTimerProjectile -= _frameTime;
            }
            if(_playerWeaponTimerMelee > 0)
            {
               _playerWeaponTimerMelee -= _frameTime;
            }
            actorRadiusCheck();
            _adventureHotColdStatus = 0;
            _loc4_ = 0;
            while(_loc4_ < _questActors.length)
            {
               _loc14_ = _questActors[_loc4_];
               if(_loc14_.getIsDead())
               {
                  delete _questActorsDict[_loc14_._actorId];
                  _loc14_.destroy();
                  _questActors.splice(_loc4_,1);
                  _loc4_--;
               }
               else
               {
                  _loc14_.heartbeat(_frameTime);
               }
               _loc4_++;
            }
            _loc4_ = _questProjectiles.length - 1;
            while(_loc4_ >= 0)
            {
               if(_questProjectiles[_loc4_].heartbeat(_frameTime))
               {
                  _questProjectiles[_loc4_].destroy();
                  _questProjectiles.splice(_loc4_,1);
               }
               _loc4_--;
            }
            _loc4_ = _questMelees.length - 1;
            while(_loc4_ >= 0)
            {
               if(_questMelees[_loc4_].heartbeat(_frameTime))
               {
                  _questMelees[_loc4_].destroy();
                  _questMelees.splice(_loc4_,1);
               }
               _loc4_--;
            }
            if(_adventureHotCold != null)
            {
               _adventureHotCold.setState(_adventureHotColdStatus);
            }
         }
      }
      
      private static function onFallingPhantomLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = param1.passback;
         _loc2_.mh.destroy();
         _loc2_.mh = null;
         _loc2_.npc = param1;
         _loc2_.npc.x = 0;
         _loc2_.npc.y = 0;
         param1.updateFallHeight(_loc2_.phantomStartY,0);
         param1.setInit();
         param1.appear();
         _loc2_.theSprite = new Sprite();
         _loc2_.theSprite.x = _loc2_.posX;
         _loc2_.theSprite.y = _loc2_.posY;
         _loc2_.theSprite.addChild(param1);
         _layerManager.room_avatars.addChild(_loc2_.theSprite);
         if(isOnscreen(_loc2_.npc))
         {
            _soundMan.play(_sounds[Math.random() < 0.5 ? (Math.random() < 0.5 ? "ajq_phntmflame1" : "ajq_phntmflame2") : (Math.random() < 0.5 ? "ajq_phntmfall1" : "ajq_phntmfall2")]);
         }
      }
      
      public static function updateFallingPhantoms() : void
      {
         var _loc1_:Object = null;
         var _loc20_:int = 0;
         var _loc18_:Number = NaN;
         var _loc16_:AvatarInfo = null;
         var _loc9_:Point = null;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc26_:* = null;
         var _loc25_:* = null;
         var _loc10_:Point = null;
         var _loc11_:Point = null;
         var _loc8_:int = 0;
         var _loc14_:int = 0;
         var _loc7_:Object = null;
         var _loc17_:QuestActor = null;
         var _loc15_:Point = null;
         var _loc12_:Point = null;
         var _loc6_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:int = 0;
         var _loc19_:Array = null;
         var _loc24_:Array = null;
         if(_fallingPhantoms.length > 0)
         {
            _loc20_ = _fallingPhantoms.length - 1;
            while(_loc20_ >= 0)
            {
               _loc1_ = _fallingPhantoms[_loc20_];
               if(_loc1_.npc != null)
               {
                  _loc18_ = 1;
                  if(_loc1_.timerElapsed < _loc1_.timerMax)
                  {
                     _loc1_.timerElapsed += _frameTime;
                     if(_loc1_.timerElapsed > _loc1_.timerMax)
                     {
                        _loc1_.timerElapsed = _loc1_.timerMax;
                     }
                     _loc18_ = _loc1_.timerElapsed / _loc1_.timerMax;
                     _loc1_.npc.updateFallHeight(_loc1_.phantomStartY * (1 - _loc18_),_loc18_);
                     if(_loc18_ >= 1 && isOnscreen(_loc1_.npc))
                     {
                        _soundMan.play(_sounds[Math.random() < 0.5 ? "ajq_phntmfdeath1" : "ajq_phntmfdeath2"]);
                     }
                  }
                  if(AvatarManager.playerAvatarWorldView != null)
                  {
                     _loc16_ = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
                     if(_loc1_.npc.attacking)
                     {
                        if(_loc16_.questHealthPercentage > 0)
                        {
                           _loc9_ = _loc1_.npc.getCollisionPoint(2);
                           _loc3_ = AvatarManager.playerAvatarWorldView.x + -15 - (_loc1_.posX + _loc9_.x);
                           _loc2_ = AvatarManager.playerAvatarWorldView.y + -40 - (_loc1_.posY + _loc9_.y);
                           _loc4_ = Number(_loc1_.npc.getCollisionRadius(2));
                           if(_loc3_ * _loc3_ + _loc2_ * _loc2_ < _loc4_ * _loc4_)
                           {
                              QuestXtCommManager.questPhantomZap("FallingPhantom",AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                           }
                        }
                        _loc1_.npc.attacking = false;
                     }
                     else if(isSideScrollQuest() && _loc18_ < 1)
                     {
                        if(_loc16_.questHealthPercentage > 0)
                        {
                           _loc9_ = _loc1_.npc.getCollisionPoint(2);
                           _loc3_ = AvatarManager.playerAvatarWorldView.x + -15 - (_loc1_.posX + _loc9_.x);
                           _loc2_ = AvatarManager.playerAvatarWorldView.y + -40 - (_loc1_.posY + _loc9_.y + _loc1_.phantomStartY * (1 - _loc18_));
                           _loc4_ = Number(_loc1_.npc.getCollisionRadius(2));
                           if(_loc3_ * _loc3_ + _loc2_ * _loc2_ < _loc4_ * _loc4_)
                           {
                              QuestXtCommManager.questPhantomZap("FallingPhantom",AvatarManager.playerAvatarWorldView.userId,AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
                           }
                        }
                     }
                  }
                  if(_loc1_.timerElapsed >= _loc1_.timerMax && _loc1_.npc.animActive == false)
                  {
                     if(_loc1_.theSprite != null && _loc1_.theSprite.parent != null)
                     {
                        _loc1_.theSprite.parent.removeChild(_loc1_.theSprite);
                     }
                     _fallingPhantoms.splice(_loc20_,1);
                  }
               }
               _loc20_--;
            }
         }
         if(AvatarManager.playerAvatarWorldView != null)
         {
            _fallingPhantomTimer -= _frameTime;
            if(_fallingPhantomTimer <= 0)
            {
               _loc21_ = AvatarManager.playerAvatarWorldView.avatarPos.x - 500 + Math.random() * 1000;
               _loc26_ = null;
               _loc25_ = null;
               _loc10_ = new Point(_loc21_,AvatarManager.playerAvatarWorldView.avatarPos.y - 300);
               _loc11_ = new Point(_loc21_,AvatarManager.playerAvatarWorldView.avatarPos.y + 300);
               _loc7_ = null;
               _loc14_ = 0;
               while(_loc14_ < _fallingPhantomVolumeActors.length && _loc26_ == null)
               {
                  _loc17_ = _questActorsDict[_fallingPhantomVolumeActors[_loc14_]];
                  if(_loc17_ != null && _loc17_._visible)
                  {
                     _loc8_ = 0;
                     while(_loc8_ < _loc17_._volumes.length && _loc26_ == null)
                     {
                        if(_roomManager.volumeManager.testPointInVolume(_loc10_,_loc17_._volumes[_loc8_]))
                        {
                           _loc26_ = _loc10_;
                        }
                        if(_roomManager.volumeManager.testPointInVolume(_loc11_,_loc17_._volumes[_loc8_]))
                        {
                           if(_loc26_ == null)
                           {
                              _loc26_ = _loc11_;
                           }
                           else
                           {
                              _loc25_ = _loc11_;
                           }
                        }
                        if(_loc26_ != null)
                        {
                           _loc7_ = _loc17_._volumes[_loc8_];
                        }
                        _loc8_++;
                     }
                  }
                  _loc14_++;
               }
               if(_loc25_ == null)
               {
                  _loc15_ = new Point();
                  _loc12_ = new Point();
                  if(_loc26_ == null)
                  {
                     _loc14_ = 0;
                     while(_loc14_ < _fallingPhantomVolumeActors.length)
                     {
                        _loc17_ = _questActorsDict[_fallingPhantomVolumeActors[_loc14_]];
                        if(_loc17_ != null && _loc17_._visible)
                        {
                           _loc8_ = 0;
                           while(_loc8_ < _loc17_._volumes.length)
                           {
                              if(checkFallingPhantomVolumeIntersect(_loc17_._volumes[_loc8_].v,_loc10_,_loc11_,_loc15_,_loc12_))
                              {
                                 _loc26_ = _loc15_;
                                 _loc25_ = _loc12_;
                                 _loc7_ = _loc17_._volumes[_loc8_];
                                 break;
                              }
                              _loc8_++;
                           }
                        }
                        _loc14_++;
                     }
                  }
                  else if(checkFallingPhantomVolumeIntersect(_loc7_.v,_loc10_,_loc11_,_loc15_,_loc12_))
                  {
                     _loc25_ = _loc15_;
                  }
               }
               _loc6_ = 0.1;
               _loc23_ = 0.4;
               if(_loc25_ != null)
               {
                  _loc22_ = 0.75;
                  _loc13_ = 1.75;
                  if(_loc7_ != null && _loc7_.message.length > 0)
                  {
                     _loc19_ = _loc7_.message.split(",");
                     _loc5_ = 0;
                     while(_loc5_ < _loc19_.length)
                     {
                        _loc24_ = _loc19_[_loc5_].split("=");
                        if(_loc24_.length == 2)
                        {
                           switch(_loc24_[0])
                           {
                              case "ratemin":
                                 _loc6_ = _loc24_[1] / 1000;
                                 break;
                              case "ratemax":
                                 _loc23_ = _loc24_[1] / 1000;
                                 break;
                              case "speedmin":
                                 _loc22_ = _loc24_[1] / 1000;
                                 break;
                              case "speedmax":
                                 _loc13_ = _loc24_[1] / 1000;
                           }
                        }
                        _loc5_++;
                     }
                  }
                  _loc1_ = {};
                  _loc1_.phantomStartY = -750;
                  _loc1_.timerMax = _loc22_ + Math.random() * (_loc13_ - _loc22_);
                  _loc1_.timerElapsed = 0;
                  _loc1_.posX = _loc21_;
                  _loc1_.posY = _loc26_.y + Math.random() * (_loc25_.y - _loc26_.y);
                  _loc1_.mh = new MediaHelper();
                  _loc1_.mh.init(getNPCDef(36).mediaRefId,onFallingPhantomLoaded,_loc1_);
                  _fallingPhantoms.push(_loc1_);
               }
               _fallingPhantomTimer = _loc6_ + Math.random() * (_loc23_ - _loc6_);
            }
         }
      }
      
      public static function checkFallingPhantomVolumeIntersect(param1:Array, param2:Point, param3:Point, param4:Point, param5:Point) : Boolean
      {
         var _loc9_:int = 0;
         var _loc8_:Point = null;
         var _loc10_:Number = param1.length - 1;
         var _loc7_:* = null;
         var _loc6_:* = null;
         _loc9_ = 0;
         while(_loc9_ < _loc10_)
         {
            param4.x = param1[_loc9_].x;
            param4.y = param1[_loc9_].y;
            param5.x = param1[_loc9_ + 1].x;
            param5.y = param1[_loc9_ + 1].y;
            _loc8_ = Collision.segIntersection(param2,param3,param4,param5);
            if(_loc8_ != null)
            {
               if(_loc7_ != null)
               {
                  _loc6_ = _loc8_;
                  break;
               }
               _loc7_ = _loc8_;
            }
            _loc9_++;
         }
         if(_loc7_ != null)
         {
            param4.x = _loc7_.x;
            param4.y = _loc7_.y;
         }
         if(_loc6_ != null)
         {
            param5.x = _loc6_.x;
            param5.y = _loc6_.y;
         }
         return _loc7_ != null;
      }
      
      public static function meleeRadiusCheck(param1:int, param2:Point, param3:int, param4:int, param5:QuestActor = null) : Array
      {
         var _loc8_:QuestActor = null;
         var _loc7_:int = 0;
         var _loc6_:Array = null;
         if(_questActorDictionary != null)
         {
            _loc7_ = 0;
            while(_loc7_ < _questActors.length)
            {
               _loc8_ = _questActors[_loc7_];
               if((_loc8_._attackable == param4 || _loc8_._attackable == 3) && (_loc8_._actorData.type == 11 || _loc8_._actorData.type == 23) && (param5 == null || param5 != _loc8_) && _loc8_.meleeHitTest(param1,param2,param3))
               {
                  if(_loc6_ == null)
                  {
                     _loc6_ = [];
                  }
                  _loc6_.push(_loc8_);
               }
               _loc7_++;
            }
         }
         return _loc6_;
      }
      
      public static function projectileRadiusCheck(param1:int, param2:int, param3:int) : QuestActor
      {
         var _loc4_:Point = null;
         var _loc6_:QuestActor = null;
         var _loc5_:int = 0;
         if(_questActorDictionary != null)
         {
            _loc4_ = new Point(param1,param2);
            _loc5_ = 0;
            while(_loc5_ < _questActors.length)
            {
               _loc6_ = _questActors[_loc5_];
               if((_loc6_._attackable == 2 || _loc6_._attackable == 3) && (_loc6_._actorData.type == 11 || _loc6_._actorData.type == 23) && _loc6_.hitTest(_loc4_,param3))
               {
                  return _loc6_;
               }
               _loc5_++;
            }
         }
         return null;
      }
      
      private static function actorRadiusCheck() : void
      {
         var _loc1_:Boolean = false;
         var _loc4_:QuestActor = null;
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:Object = null;
         if(AvatarManager.playerAvatarWorldView && (AvatarManager.playerAvatarWorldView.moving || _playerAvatarCurrentAnim != AvatarManager.playerAvatarWorldView.animId))
         {
            _playerAvatarCurrentAnim = AvatarManager.playerAvatarWorldView.animId;
            if(_questActorDictionary != null)
            {
               _loc1_ = false;
               _loc2_ = 0;
               while(_loc2_ < _questActors.length)
               {
                  _loc4_ = _questActors[_loc2_];
                  if(_loc4_.onRadiusTest())
                  {
                     _loc1_ = true;
                  }
                  _loc2_++;
               }
               if(!_loc1_)
               {
                  _lastGoodAvatarX = AvatarManager.playerAvatarWorldView.avatarPos.x;
                  _lastGoodAvatarY = AvatarManager.playerAvatarWorldView.avatarPos.y;
               }
            }
            _loc5_ = _roomManager.getNearestQuestRespawnPointPlayerIsIn(AvatarManager.playerAvatarWorldView.avatarPos);
            if(_loc5_ != null)
            {
               if(_loc5_.hasOwnProperty("name"))
               {
                  _loc3_ = _questActorDictionary[_loc5_.name];
               }
               if(_loc3_ == null || _loc3_.visible)
               {
                  _nearestRespawnPoint = _loc5_;
               }
            }
            _playerInStealthVolume = _roomManager.volumeManager.testStealthVolumes(AvatarManager.playerAvatarWorldView.avatarPos) != null;
         }
      }
      
      public static function setActorDictionary(param1:Dictionary, param2:String) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:String = null;
         var _loc3_:Array = null;
         if(param1 != null)
         {
            _totalGemsEarned = 0;
            _totalXPEarned = 0;
            _playerCrystalCount = 0;
            _playerOrbCountTotal = 0;
            _guiTimerLocal = 0;
         }
         _defeatedPopUpTimer = 0;
         _questScriptTimeStamp = param2;
         if(_questActors != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _questActors.length)
            {
               _questActors[_loc5_].destroy();
               _loc5_++;
            }
            _questActors = new Vector.<QuestActor>();
         }
         _questActorDictionary = param1;
         _gameIdleTimer = 0;
         gMainFrame.stage.addEventListener("mouseDown",resetMouseDownIdleTimer,false);
         gMainFrame.stage.addEventListener("mouseMove",resetMouseMoveIdleTimer,false);
         var _loc7_:Object = _questActorDictionary["diff_level"];
         if(_loc7_ != null)
         {
            _questDifficultyLevel = _loc7_.state;
         }
         else
         {
            _questDifficultyLevel = 0;
         }
         _questActorGroups = new Dictionary();
         for(var _loc8_ in _questActorDictionary)
         {
            _loc4_ = int(_loc8_.lastIndexOf("__"));
            if(_loc4_ != -1)
            {
               _loc6_ = _loc8_.substring(0,_loc4_);
               _loc3_ = _questActorGroups[_loc6_];
               if(_loc3_ == null)
               {
                  _loc3_ = [];
                  _questActorGroups[_loc6_] = _loc3_;
               }
               _loc3_.push(_loc8_);
            }
         }
         startFadeIn();
      }
      
      public static function clearPlayerDictionary() : void
      {
         if(_questPlayersDict != null)
         {
            for(var _loc1_ in _questPlayersDict)
            {
               _questPlayersDict[_loc1_].destroy();
               delete _questPlayersDict[_loc1_];
            }
         }
         _questPlayersDict = null;
      }
      
      private static function stopLightAnim(param1:Event) : void
      {
         var _loc2_:Loader = _playerTorch.getChildAt(0) as Loader;
         (_loc2_.content as MovieClip).stop();
         _playerTorch.removeEventListener("complete",stopLightAnim);
      }
      
      public static function canGoInPlatformAdventure(param1:int, param2:Boolean) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         if(_platformScriptIdsOrdered)
         {
            _loc3_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(435));
            _loc4_ = 0;
            while(_loc4_ < _platformScriptIdsOrdered.length)
            {
               if(_platformScriptIdsOrdered[_loc4_] == param1)
               {
                  if(_loc4_ == 0)
                  {
                     return true;
                  }
                  return BitUtility.isBitSetForNumber(_loc4_ - 1,_loc3_);
               }
               _loc4_++;
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            GenericListXtCommManager.requestGenericList(566,onPlatformerListLoaded,{
               "scriptIdToStart":param1,
               "autoStart":param2
            });
         }
         return false;
      }
      
      private static function onPlatformerListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _platformScriptIdsOrdered = param2;
         if(param3)
         {
            DarkenManager.showLoadingSpiral(false);
            _roomManager.checkAndStartAdventure(param3.scriptIdToStart,param3.autoStart);
         }
      }
      
      public static function sceneAssetsLoaded(param1:Array) : void
      {
         var _loc9_:Object = null;
         var _loc7_:int = 0;
         var _loc14_:Object = null;
         var _loc15_:Number = NaN;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc20_:Object = null;
         var _loc5_:Array = null;
         var _loc12_:Object = null;
         var _loc16_:Point = null;
         var _loc18_:Array = null;
         var _loc4_:Object = null;
         var _loc19_:Object = null;
         var _loc2_:int = 0;
         var _loc22_:int = 0;
         var _loc10_:QuestPlayerData = null;
         var _loc21_:MediaHelper = null;
         var _loc13_:int = 0;
         var _loc17_:String = null;
         if(param1.length > 1)
         {
            _loc7_ = _roomManager.roomDefId;
            _loc14_ = RoomXtCommManager.getRoomDef(_loc7_);
            if(_loc14_ && _loc14_.pathName.indexOf("queststaging_433") != -1)
            {
               if(_platformScriptIdsOrdered == null)
               {
                  GenericListXtCommManager.requestGenericList(566,onPlatformerListLoaded);
               }
               _loc15_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(435));
               _loc6_ = 1;
               while(_loc6_ < param1.length)
               {
                  _loc3_ = int(String(param1[_loc6_].name).substring(8));
                  if(BitUtility.isBitSetForNumber(_loc3_ - 2,_loc15_) == false)
                  {
                     param1[_loc6_].s.visible = false;
                  }
                  _loc6_++;
               }
            }
         }
         if(_questActorDictionary != null)
         {
            _nearestRespawnPoint = null;
            if(_queueFadeIn)
            {
               _queueFadeIn = false;
               startFadeIn();
            }
            if(_playMusicOnLoad)
            {
               if(_SFX_Music[_currentMusic] == null)
               {
                  _loc9_ = _streamsLUT[_currentMusic];
                  _SFX_Music[_currentMusic] = _soundMan.addStream(_loc9_.name,_loc9_.vol);
               }
               _soundMan.playStream(_SFX_Music[_currentMusic],0,99999);
               _playMusicOnLoad = false;
            }
            if(_questObjectiveText != null && _questObjectiveText.length > 0 && GuiManager.mainHud.objBar != null)
            {
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
               LocalizationManager.translateId(GuiManager.mainHud.questObjectiveTxt,int(_questObjectiveText));
               GuiManager.mainHud.objBar.gotoAndPlay("on");
            }
            else if(GuiManager.mainHud.questObjectiveTxt != null)
            {
               GuiManager.mainHud.questObjectiveTxt.text = "";
            }
            if(GuiManager.mainHud.questPlayersBtn != null)
            {
               GuiManager.mainHud.questPlayersBtn.activateGrayState(_questStartingPlayerCount <= 1);
            }
            if(_seedInventory == null)
            {
               _seedInventory = new SeedInventoryHandling();
               _seedInventory.init(_questSeeds);
            }
            _paused = false;
            if(AvatarManager.playerAvatarWorldView)
            {
               _lastGoodAvatarX = AvatarManager.playerAvatarWorldView.avatarPos.x;
               _lastGoodAvatarY = AvatarManager.playerAvatarWorldView.avatarPos.y;
            }
            else
            {
               _lastGoodAvatarX = 0;
               _lastGoodAvatarY = 0;
            }
            _roomManager.removeMiniMap();
            _fallingPhantomVolumeActors = null;
            for(var _loc11_ in _questActorDictionary)
            {
               _loc20_ = _questActorDictionary[_loc11_];
               if(_loc20_ != null)
               {
                  switch(_loc20_.type)
                  {
                     case 14:
                     case 5:
                     case 3:
                     case 22:
                     case 24:
                     case 26:
                        _loc5_ = _roomManager.volumeManager.findVolume(_loc11_);
                        if(_loc5_ != null)
                        {
                           initQuestActor(_loc11_,0,0,null,null);
                           if(_loc20_.type == 26)
                           {
                              if(_fallingPhantomVolumeActors == null)
                              {
                                 _fallingPhantomVolumeActors = [];
                              }
                              _fallingPhantomVolumeActors.push(_loc11_);
                           }
                        }
                        break;
                     case 9:
                        _loc12_ = _roomManager.findSpawn(null,_loc11_);
                        if(_loc12_ != null)
                        {
                           _loc16_ = new Point(_loc12_.x,_loc12_.y);
                           _roomManager.convertToWorldSpace(_loc16_);
                           initQuestActor(_loc11_,0,0,null,_loc16_);
                        }
                        break;
                     case 2:
                        _loc18_ = _roomManager.findLayers(_loc11_);
                        if(_loc18_ != null)
                        {
                           for each(var _loc8_ in _loc18_)
                           {
                              if(_loc20_.state > 0)
                              {
                                 if(_loc8_.s.content["setState"] != null)
                                 {
                                    _loc8_.s.content.setState(_loc20_.state,true);
                                 }
                              }
                              if(_loc8_.s.content.hasOwnProperty("setProgress"))
                              {
                                 _loc8_.s.content.setProgress(_loc20_.progress);
                              }
                              _loc8_.s.content.visible = _loc20_.visible;
                           }
                        }
                        break;
                     default:
                        if(_loc20_.spawnedFromActor != null)
                        {
                           doSpawnToRoot(_loc20_);
                        }
                        break;
                  }
               }
            }
            _roomManager.createMiniMap();
            if(isSideScrollQuest())
            {
               AvatarManager.playerAvatarWorldView.loadSideScrollArrow();
            }
            _sceneLoaded = true;
            _playerTorch = addTorch(AvatarManager.playerAvatarWorldView,0.7,-15,-50);
            if(_playerTorch)
            {
               _playerTorch.addEventListener("complete",stopLightAnim,false,0,true);
            }
            while(_addTorchQueue.length)
            {
               _loc4_ = _addTorchQueue.pop();
               addTorch(_loc4_.actor,_loc4_.scale,_loc4_.offsetX,_loc4_.offsetY);
            }
            _loc19_ = _questActorDictionary["questready"];
            if(_loc19_ != null && _loc19_.state == 0)
            {
               QuestXtCommManager.questActorTriggered("questready");
            }
            if(_questActorDictionary["gui_ffm"])
            {
               _guiElementsSkipBtn = new MovieClip();
               _guiElementsSkipBtnMh = new MediaHelper();
               _guiElementsSkipBtnMh.init(392,skipButtonMediaCallback,true);
               _loc2_ = 0;
               while(_loc2_ < _guiElementsGuiManager.length)
               {
                  if(GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]])
                  {
                     _loc19_ = _questActorDictionary[_guiElementsGuiManager[_loc2_]];
                     if(_loc19_.state >= 0 && _loc19_.state <= 2)
                     {
                        if(GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].hasOwnProperty("setButtonState"))
                        {
                           if(GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].currentFrameLabel == "old")
                           {
                              GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].gotoAndStop("new");
                           }
                           GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].setButtonState(_loc19_.state);
                        }
                        if(_guiElementsGuiManager[_loc2_ + 1] == "money")
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].addEventListener("mouseOver",guiDownHandler,false,0,true);
                        }
                        else
                        {
                           GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]].addEventListener("mouseDown",guiDownHandler,false,0,true);
                        }
                        if(_guiElementsGuiManager[_loc2_ + 1] == "charWindow")
                        {
                           GuiManager.grayHudAvatar(_loc19_.state == 0);
                        }
                     }
                  }
                  _loc2_ += 2;
               }
               if(GuiManager.mainHud.emailChatBtn)
               {
                  GuiManager.mainHud.emailChatBtn.activateGrayState(true);
               }
            }
            if(_questPlayersSwitched)
            {
               for(var _loc23_ in _questPlayersSwitched)
               {
                  _loc22_ = int(_questPlayersSwitched[_loc23_]);
                  _loc10_ = getQuestPlayerData(_loc23_ as int);
                  if(_loc10_ != null)
                  {
                     _loc10_.setAvatarSwitched(_loc22_);
                  }
               }
            }
            if(_questActorDictionary["gui_timer"] != null || _questActorDictionary["gui_time_max"])
            {
               _loc21_ = new MediaHelper();
               _loc21_.init(2710,onTimerLoaded);
            }
            if(_questActorDictionary["hot_cold"] != null)
            {
               _loc21_ = new MediaHelper();
               _loc21_.init(5488,onHotColdLoaded);
            }
            loop8:
            switch(getAdventureType() - 1)
            {
               case 0:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
               case 7:
               case 8:
                  _loc21_ = new MediaHelper();
                  _loc21_.init(2745,onGuiGoalLoaded,{"goalId":1});
                  break;
               default:
                  if(_questActorDictionary["showorbcount"] != null)
                  {
                     _loc21_ = new MediaHelper();
                     _loc21_.init(2745,onGuiGoalLoaded,{"goalId":1});
                     break;
                  }
                  _loc13_ = 1;
                  while(true)
                  {
                     if(_loc13_ > 5)
                     {
                        break loop8;
                     }
                     _loc17_ = "gui_goal" + _loc13_ + "a";
                     if(!_questActorDictionary[_loc17_])
                     {
                        break loop8;
                     }
                     _loc21_ = new MediaHelper();
                     _loc21_.init(2745,onGuiGoalLoaded,{"goalId":_loc13_});
                     _loc13_++;
                  }
                  break;
            }
         }
      }
      
      private static function guiDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!param1.currentTarget.isGray)
         {
            _loc2_ = 0;
            while(_loc2_ < _guiElementsGuiManager.length)
            {
               if(param1.currentTarget == GuiManager.mainHud[_guiElementsGuiManager[_loc2_ + 1]])
               {
                  if(_guiElementsGuiManager[_loc2_ + 1] == "money")
                  {
                     setTimeout(QuestXtCommManager.questActorTriggered,2000,_guiElementsGuiManager[_loc2_]);
                     break;
                  }
                  QuestXtCommManager.questActorTriggered(_guiElementsGuiManager[_loc2_]);
                  break;
               }
               _loc2_ += 2;
            }
         }
      }
      
      private static function avEdDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!param1.currentTarget.hasOwnProperty("isGray") || !param1.currentTarget.isGray)
         {
            _loc2_ = 0;
            while(_loc2_ < _guiElementsAvatarEditor.length)
            {
               if(param1.currentTarget.name == _guiElementsAvatarEditor[_loc2_ + 1])
               {
                  QuestXtCommManager.questActorTriggered(_guiElementsAvatarEditor[_loc2_]);
                  break;
               }
               _loc2_ += 2;
            }
         }
      }
      
      private static function skipButtonMediaCallback(param1:MovieClip) : void
      {
         _guiElementsSkipBtn.addChild(param1);
         GuiManager.guiLayer.addChild(_guiElementsSkipBtn);
         _guiElementsSkipBtn.x = 810;
         _guiElementsSkipBtn.y = 420;
         _guiElementsSkipBtn.visible = true;
         _guiElementsSkipBtn.addEventListener("mouseDown",guiElementsSkipBtnPress,false,0,true);
         _guiElementsSkipBtnMh.destroy();
         _guiElementsSkipBtnMh = null;
      }
      
      public static function guiElementsSkipBtnPress(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/newffm/#skipButton");
         commandExit();
         AvatarXtCommManager.sendAvatarPendingFlagsUpdate(0);
         gMainFrame.userInfo.firstFiveMinutes = 1;
         _guiElementsSkipBtn.visible = false;
      }
      
      public static function recycle(param1:int, param2:Object) : void
      {
         if(_assetPool[param1] == null)
         {
            _assetPool[param1] = [];
         }
         _assetPool[param1].push(param2);
      }
      
      private static function getQuestAsset(param1:int) : Object
      {
         var _loc2_:Array = _assetPool[param1];
         if(_loc2_ && _loc2_.length > 0)
         {
            return _loc2_.pop();
         }
         return null;
      }
      
      public static function initQuestActor(param1:String, param2:int, param3:int, param4:Object = null, param5:Point = null, param6:Point = null, param7:Boolean = false, param8:String = null) : void
      {
         var _loc10_:int = 0;
         var _loc9_:Boolean = false;
         var _loc13_:QuestActor = null;
         var _loc12_:Array = null;
         if(_questActorDictionary != null)
         {
            if(param4 == null)
            {
               param4 = _questActorDictionary[param1];
            }
            if(param4 != null && param8 != null && param8.length > 0)
            {
               param4.extendedParameters = param8;
            }
            if(param4 != null)
            {
               if(param7)
               {
                  if(param4.hasOwnProperty("previouslyPickedUp") && param4.previouslyPickedUp)
                  {
                     return;
                  }
               }
               if(!param4.hasOwnProperty("actorPos"))
               {
                  if(param4.type == 11)
                  {
                     param4.actorOrigPos = new Point(param5.x,param5.y);
                     param4.origInnerRadius = param2;
                     param4.origOuterRadius = param3;
                     param4.origPriority = _actorPriority;
                  }
                  param4.actorPos = param5;
               }
               if(_questActorsDict)
               {
                  if(_questActorsDict[param1] != null)
                  {
                     _questActorsDict[param1].destroy();
                     if(_questActors)
                     {
                        _loc10_ = 0;
                        while(_loc10_ < _questActors.length)
                        {
                           if(_questActors[_loc10_]._actorId == param1)
                           {
                              _questActors.splice(_loc10_,1);
                              break;
                           }
                           _loc10_++;
                        }
                     }
                  }
               }
               else
               {
                  _questActorsDict = new Dictionary();
               }
               if(_questActors == null)
               {
                  _questActors = new Vector.<QuestActor>();
               }
               _loc9_ = true;
               switch(param4.type)
               {
                  case 12:
                  case 11:
                  case 23:
                     if(param4.healthPercent == 0)
                     {
                     }
               }
               if(_loc9_)
               {
                  if(param4.type == 11 || param4.type == 12 || param4.type == 23 || param4.type == 21 || param4.type == 1 || param4.type == 25)
                  {
                  }
                  if(_loc13_ == null)
                  {
                     _loc13_ = new QuestActor();
                     _loc13_.initActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  else
                  {
                     _loc13_.resetActor(param1,param4,param2,param3,_actorPriority++,param6);
                  }
                  _loc13_.setRequireClick(param4.requireClick);
                  _loc13_.setVisible(param4.visible);
                  _questActors.push(_loc13_);
                  _questActorsDict[param1] = _loc13_;
                  var _loc14_:* = param4.type;
                  if(2 === _loc14_)
                  {
                     _loc12_ = _roomManager.findLayers(param1);
                     if(_loc12_ != null)
                     {
                        for each(var _loc11_ in _loc12_)
                        {
                           if(_loc11_.s.content["setState"] != null)
                           {
                              _loc11_.s.content.setState(param4.state,true);
                           }
                           if(_loc11_.s.content.hasOwnProperty("setProgress"))
                           {
                              _loc11_.s.content.setProgress(param4.progress);
                           }
                           _loc11_.s.content.visible = param4.visible;
                        }
                     }
                  }
               }
            }
         }
      }
      
      public static function commandDebugSay(param1:int, param2:Object) : void
      {
         new SBOkPopup(GuiManager.guiLayer,param2[param1++],true);
      }
      
      public static function commandNotify(param1:int, param2:Object) : void
      {
         _questObjectiveText = param2[param1++];
         if(GuiManager.mainHud.questObjectiveTxt != null && GuiManager.mainHud.objBar != null)
         {
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#notify/" + _questObjectiveText);
            LocalizationManager.translateId(GuiManager.mainHud.questObjectiveTxt,int(_questObjectiveText));
            GuiManager.mainHud.objBar.gotoAndPlay("on");
            playSound("ajq_questNotification");
         }
      }
      
      public static function commandSay(param1:int, param2:Object) : void
      {
         var _loc4_:int = 0;
         _questCommandActor = null;
         _questCommandActorState = -1;
         var _loc5_:QuestActor = _questActorsDict[param2[param1++]];
         var _loc3_:int = int(param2[param1++]);
         var _loc6_:String = LocalizationManager.translateIdOnly(_loc3_);
         var _loc7_:Object = EmoticonUtility.matchEmoteString(_loc6_,true);
         if(_loc7_ != null && _loc7_.sprite != null)
         {
            _loc5_.setEmote(_loc7_.sprite);
         }
         else
         {
            switch((_loc4_ = int(param2[param1++])) - 1)
            {
               case 0:
                  if(_loc5_ != null)
                  {
                     _loc5_.setChatBalloonText(_loc6_,_loc5_.npcDef.avatarRefId == 32);
                     GuiManager.chatHist.addMessage("","","",_loc6_);
                  }
                  break;
               case 1:
                  if(_loc5_ != null)
                  {
                     _loc5_.setChatBalloonText(_loc6_,false,true);
                  }
                  break;
               default:
                  if(_talkingPopup != null)
                  {
                     onTalkingPopupClose(null);
                  }
                  SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + _loc3_);
                  showTalkingDialog(GuiManager.guiLayer,_loc6_.split("|"),_loc5_ != null ? _loc5_.talkingHeadMediaRef : 0);
            }
         }
      }
      
      public static function commandAsk(param1:int, param2:Object) : void
      {
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         var _loc3_:int = int(param2[param1++]);
         _questCommandActor = param2[param1++];
         _questCommandActorState = param2[param1++];
         var _loc4_:QuestActor = _questActorsDict[_questCommandActor];
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#dialog/" + param2[param1]);
         showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(param2[param1++]).split("|"),_loc4_ != null && _questCommandActor != "ask_actor" ? _loc4_.talkingHeadMediaRef : (_questCommandActor == "ask_actor" ? -1 : 0),-1,_loc3_ == 1);
      }
      
      private static function onCommandAskConfirm(param1:Boolean) : void
      {
         if(_questCommandActor != "" && _questCommandActorState != -1)
         {
            QuestXtCommManager.questAskComplete(_questCommandActor,_questCommandActorState,param1 == true ? 1 : 0);
            _questCommandActor = null;
            _questCommandActorState = -1;
         }
         if(getAdventureType() == 4)
         {
            if(_adventureGoals[1])
            {
               _adventureGoals[1].setOKPressed();
            }
         }
      }
      
      public static function commandSetState(param1:int, param2:Object, param3:Boolean) : void
      {
         var _loc10_:Object = null;
         var _loc7_:String = null;
         var _loc5_:int = 0;
         var _loc11_:* = false;
         var _loc14_:* = false;
         var _loc8_:Boolean = false;
         var _loc4_:int = 0;
         var _loc12_:AvatarEditor = null;
         var _loc13_:Object = null;
         var _loc9_:Array = null;
         if(_questActorDictionary != null)
         {
            _loc7_ = param2[param1++];
            _loc10_ = _questActorDictionary[_loc7_];
            if(_loc7_ == "gui_timer")
            {
               _soundMan.play(_sounds["aj_play_timer_tick1"]);
            }
            if(_loc10_ != null)
            {
               _loc5_ = int(param2[param1++]);
               if(_loc7_ == "gui_time_max")
               {
                  _guiTimerLocal = _loc5_;
                  if(_adventureTimer != null && _loc5_ > 0)
                  {
                     _adventureTimer.visible = true;
                  }
               }
               if(_loc7_ == "live_players")
               {
                  if(GuiManager.mainHud.questPlayersBtn != null)
                  {
                     GuiManager.mainHud.questPlayersBtn.activateGrayState(_loc5_ <= 1);
                     if(GuiManager.mainHud.playersCont.visible)
                     {
                        if(_loc5_ <= 1)
                        {
                           GuiManager.mainHud.playersCont.visible = false;
                           GuiManager.mainHud.questPlayersBtn.downToUpState();
                        }
                     }
                  }
               }
               if(param3)
               {
                  _loc10_.state = _loc5_;
               }
               else
               {
                  _loc11_ = param2[param1++] == 1;
                  _loc14_ = param2[param1++] == 1;
                  if(_loc10_.type == 15 && isDynamicallyJoinableQuest())
                  {
                     if(_loc10_.state == _loc5_ && _loc10_.visible != _loc11_)
                     {
                        return;
                     }
                  }
                  _loc10_.requireClick = _loc14_;
                  _loc10_.visible = _loc11_;
                  _loc10_.state = _loc5_;
                  if(ExternalInterface.available)
                  {
                     ExternalInterface.call("mrc",["dm","ACS," + _loc7_ + "," + _loc5_]);
                  }
                  loop3:
                  switch(_loc10_.type)
                  {
                     case 28:
                        _loc8_ = false;
                        _loc4_ = 0;
                        while(_loc4_ <= _guiElementsGuiManager.length)
                        {
                           if(_loc7_ == _guiElementsGuiManager[_loc4_])
                           {
                              if(GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]])
                              {
                                 if(_guiElementsGuiManager[_loc4_ + 1] == "money")
                                 {
                                    GuiManager.updateMainHudButtons(false,{
                                       "btnName":_guiElementsGuiManager[_loc4_ + 1],
                                       "show":true
                                    });
                                 }
                                 if(GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].hasOwnProperty("setButtonState"))
                                 {
                                    if(GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].currentFrameLabel == "old")
                                    {
                                       GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].gotoAndStop("new");
                                    }
                                    GuiManager.mainHud[_guiElementsGuiManager[_loc4_ + 1]].setButtonState(_loc10_.state);
                                 }
                                 if(_guiElementsGuiManager[_loc4_ + 1] == "charWindow")
                                 {
                                    GuiManager.grayHudAvatar(_loc10_.state == 0);
                                 }
                              }
                              _loc8_ = true;
                              break;
                           }
                           _loc4_ += 2;
                        }
                        if(!_loc8_)
                        {
                           _loc12_ = GuiManager.avatarEditor;
                           if(_loc12_ != null && _loc12_.avEditor != null)
                           {
                              _loc4_ = 0;
                              while(true)
                              {
                                 if(_loc4_ > _guiElementsAvatarEditor.length)
                                 {
                                    break loop3;
                                 }
                                 if(_loc7_ == _guiElementsAvatarEditor[_loc4_])
                                 {
                                    _loc13_ = _loc12_.avEditor[_guiElementsAvatarEditor[_loc4_ + 1]];
                                    if(_loc13_ == null)
                                    {
                                       _loc13_ = _loc12_[_guiElementsAvatarEditor[_loc4_ + 1]];
                                    }
                                    if(_loc13_)
                                    {
                                       if(_loc10_.state == 2)
                                       {
                                          switch(_guiElementsAvatarEditor[_loc4_ + 1])
                                          {
                                             case "colorsTabUp":
                                                _loc12_.openTab(0);
                                                break;
                                             case "eyesTabUp":
                                                _loc12_.openTab(2);
                                                break;
                                             case "patternTabUp":
                                                _loc12_.openTab(1);
                                          }
                                       }
                                       if(_loc13_.hasOwnProperty("setButtonState"))
                                       {
                                          if(_loc13_.currentFrameLabel == "old")
                                          {
                                             _loc13_.gotoAndStop("new");
                                          }
                                          _loc13_.setButtonState(_loc10_.state);
                                       }
                                       else if(_guiElementsAvatarEditor[_loc4_ + 1] == "fiveMinCursor")
                                       {
                                          _loc13_.visible = _loc10_.state != 0;
                                          if(_loc10_.state != 0)
                                          {
                                             _loc13_.gotoAndPlay("state" + _loc10_.state);
                                          }
                                       }
                                    }
                                    _loc8_ = true;
                                    break loop3;
                                 }
                                 _loc4_ += 2;
                              }
                           }
                        }
                        break;
                     case 2:
                        _loc9_ = _roomManager.findLayers(_loc7_);
                        if(_loc9_ != null)
                        {
                           for each(var _loc6_ in _loc9_)
                           {
                              if(_loc6_.s != null && _loc6_.s.content != null)
                              {
                                 if(_loc6_.s.content["setState"] != null)
                                 {
                                    _loc6_.s.content.setState(_loc10_.state);
                                 }
                                 _loc6_.s.content.visible = _loc11_;
                              }
                           }
                        }
                        break;
                     case 7:
                        QuestXtCommManager.questActorTriggered(_loc7_);
                        break;
                     default:
                        _loc10_ = _questActorsDict[_loc7_];
                        if(_loc10_ != null)
                        {
                           _loc10_.setRequireClick(_loc14_);
                           _loc10_.setVisible(_loc11_);
                           _loc10_.onRadiusTest();
                           break;
                        }
                  }
               }
            }
         }
      }
      
      public static function commandTeleport(param1:int, param2:Object) : void
      {
         var _loc5_:Object = null;
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc3_:* = param2[param1++] == "1";
         if(_loc3_)
         {
            _loc4_ = param2[param1++];
            _loc5_ = _questActorsDict[_loc4_];
            if(_loc5_ != null)
            {
               _roomManager.teleportPlayer(_loc5_.x,_loc5_.y,true);
            }
         }
         else
         {
            _loc6_ = param2[param1++];
            _roomManager.setGotoSpawnPoint(_loc6_);
         }
      }
      
      public static function commandFocus(param1:int, param2:Object) : void
      {
         var _loc6_:Object = null;
         var _loc3_:String = null;
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Array = null;
         var _loc7_:int = 0;
         var _loc4_:Array = null;
         _loc3_ = param2[param1++];
         _loc6_ = _questActorsDict[_loc3_];
         if(_loc6_ != null)
         {
            _loc8_ = 0.75;
            _loc5_ = 1.5;
            _loc10_ = 0.75;
            if(_loc6_._actorData.extendedParameters != null)
            {
               _loc9_ = _loc6_._actorData.extendedParameters.split(",");
               _loc7_ = 0;
               while(_loc7_ < _loc9_.length)
               {
                  switch((_loc4_ = _loc9_[_loc7_].split("="))[0])
                  {
                     case "camto":
                        _loc8_ = Number(_loc4_[1]);
                        break;
                     case "camstay":
                        _loc5_ = Number(_loc4_[1]);
                        break;
                     case "camreturn":
                        _loc10_ = Number(_loc4_[1]);
                  }
                  _loc7_++;
               }
            }
            _roomManager.setCameraFocus(new Point(_loc6_.x,_loc6_.y),_loc8_,_loc5_,_loc10_,true);
         }
      }
      
      public static function commandExit(param1:String = null) : void
      {
         _questExitPending = true;
         _questObjectiveText = "";
         AvatarManager.setPlayerAttachmentEmot(0,null,0,false);
         if(_questActorDictionary["gui_ffm"])
         {
            QuestXtCommManager.sendQuestExit("ffm");
            gMainFrame.userInfo.firstFiveMinutes = 1;
            GuiManager.rebuildMainHud();
         }
         else if(param1 != null && param1.length > 0)
         {
            QuestXtCommManager.sendQuestExit(param1);
         }
         else
         {
            _roomManager.setGotoSpawnPoint("quest_end");
            QuestXtCommManager.sendQuestExit("");
         }
      }
      
      public static function commandTakeItem(param1:int, param2:Object) : void
      {
         AvatarManager.setPlayerAttachmentEmot(0,null,0);
         _delayMinigameLaunches = true;
      }
      
      public static function commandGame(param1:int, param2:Object) : void
      {
         var _loc3_:int = int(param2[param1++]);
         _questCommandActorMiniGame = param2[param1++];
         _questCommandActorStateMiniGame = param2[param1++];
         if(!_delayMinigameLaunches)
         {
            launchMinigame(_loc3_);
         }
         else
         {
            _delayMinigameID = _loc3_;
         }
      }
      
      public static function launchQueuedGame() : void
      {
         _delayMinigameLaunches = false;
         if(_delayMinigameID >= 0)
         {
            launchMinigame(_delayMinigameID);
            _delayMinigameID = -1;
         }
      }
      
      public static function launchMinigame(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         MinigameManager.handleGameClick({
            "idx":5,
            "r":30,
            "spawn":"spawn",
            "type":0,
            "typeDefId":param1,
            "x":0,
            "y":0
         },null,true,null);
         _roomManager.setGotoSpawnLocation(_lastGoodAvatarX,_lastGoodAvatarY);
      }
      
      public static function handleCommand(param1:Object, param2:Boolean) : void
      {
         var _loc3_:int = 2;
         var _loc4_:int;
         switch(_loc4_ = int(param1[_loc3_++]))
         {
            case 1:
               commandSetState(_loc3_,param1,param2);
               break;
            case 38:
               commandNotify(_loc3_,param1);
               break;
            case 2:
               commandSay(_loc3_,param1);
               break;
            case 3:
               commandAsk(_loc3_,param1);
               break;
            case 4:
               commandGame(_loc3_,param1);
               break;
            case 14:
               commandTeleport(_loc3_,param1);
               break;
            case 15:
               commandFocus(_loc3_,param1);
               break;
            case 19:
               commandExit();
               break;
            case 7:
               commandTakeItem(_loc3_,param1);
               break;
            case 1001:
               commandDebugSay(_loc3_,param1);
         }
      }
      
      public static function showTalkingDialog(param1:DisplayLayer, param2:Array, param3:int = 0, param4:int = -1, param5:Boolean = false, param6:Function = null, param7:Object = null) : void
      {
         var textIndex:int;
         var avt:AvatarView;
         var o:Object;
         var popupLayer:DisplayLayer = param1;
         var fullTextSplit:Array = param2;
         var talkingHeadMediaRef:int = param3;
         var streamId:int = param4;
         var useYesNo:Boolean = param5;
         var customCallback:Function = param6;
         var customPassback:Object = param7;
         if(_talkingPopup)
         {
            DarkenManager.showLoadingSpiral(false);
            if(talkingHeadMediaRef == -1)
            {
               if(useYesNo)
               {
                  new SBYesNoPopup(popupLayer,fullTextSplit[0],true,onConfirmBtn);
               }
               else
               {
                  new SBOkPopup(popupLayer,fullTextSplit[0],true,onConfirmBtn);
               }
               return;
            }
            if(talkingHeadMediaRef == 0)
            {
               _talkingPopup.gotoAndStop("questingPopup");
               _talkingPopup.txt.autoSize = "center";
               _talkingPopup.txt.text = fullTextSplit.length > 1 ? fullTextSplit[1] : fullTextSplit[0];
               GuiManager.chatHist.addMessage("","","",_talkingPopup.txt.text);
            }
            else
            {
               _talkingPopup.gotoAndStop("talkingHead");
               _talkingPopup.txt.autoSize = "center";
               _talkingPopup.talkingHeadTitleTxt.text = fullTextSplit[0];
               _talkingPopup.txt.text = fullTextSplit[1];
               textIndex = 1;
               while(textIndex < fullTextSplit.length)
               {
                  GuiManager.chatHist.addMessage("","","",fullTextSplit[textIndex]);
                  textIndex++;
               }
               while(_talkingPopup.viewHolder.itemWindow.numChildren > 1)
               {
                  o = _talkingPopup.viewHolder.itemWindow.getChildAt(1);
                  if(o is Avatar)
                  {
                     o.destroy();
                  }
                  _talkingPopup.viewHolder.itemWindow.removeChildAt(1);
               }
               if(!_talkingLoadingSpiral)
               {
                  _talkingLoadingSpiral = new LoadingSpiral(_talkingPopup.itemRenderPlaceholder.itemWindow,_talkingPopup.itemRenderPlaceholder.itemWindow.width * 0.5,_talkingPopup.itemRenderPlaceholder.itemWindow.height * 0.5);
               }
               else
               {
                  _talkingLoadingSpiral.visible = true;
               }
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(talkingHeadMediaRef,onTalkingHeadMediaLoaded);
            }
            _talkingPopupFullText = fullTextSplit;
            _talkingPopupCurrTextPage = 1;
            _talkingPopup.useYesNo = useYesNo;
            _talkingPopup.customCallback = customCallback;
            _talkingPopup.customPassback = customPassback;
            if(useYesNo && _talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
            {
               _talkingPopup.okBtn.visible = false;
               _talkingPopup.nextBtn.visible = false;
               _talkingPopup.yesBtn.addEventListener("mouseDown",onYesBtn,false,0,true);
               _talkingPopup.noBtn.addEventListener("mouseDown",onNoBtn,false,0,true);
            }
            else
            {
               _talkingPopup.yesBtn.visible = false;
               _talkingPopup.noBtn.visible = false;
               if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
               {
                  _talkingPopup.nextBtn.visible = false;
               }
               else
               {
                  _talkingPopup.okBtn.visible = false;
                  if(useYesNo)
                  {
                     _talkingPopup.yesBtn.addEventListener("mouseDown",onYesBtn,false,0,true);
                     _talkingPopup.noBtn.addEventListener("mouseDown",onNoBtn,false,0,true);
                  }
               }
               _talkingPopup.okBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
               _talkingPopup.nextBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
            }
            updateTalkingPopupSize();
            with(_talkingPopup)
            {
               
               addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
               bx.addEventListener(MouseEvent.MOUSE_DOWN,onTalkingPopupClose,false,0,true);
               if(useYesNo)
               {
                  bx.visible = false;
               }
               else
               {
                  bx.visible = true;
               }
               x = MainFrame.VIEW_WIDTH * 0.5;
               y = MainFrame.VIEW_HEIGHT * 0.5;
            }
            popupLayer.addChild(_talkingPopup);
            DarkenManager.darken(_talkingPopup);
         }
         else if(!_isLoadingTalkingPopup)
         {
            _isLoadingTalkingPopup = true;
            DarkenManager.showLoadingSpiral(true);
            _mediaLoader = new MediaHelper();
            _mediaLoader.init(1789,onTalkingDialogLoaded,{
               "popupLayer":popupLayer,
               "fullTextSplit":fullTextSplit,
               "talkingHeadMediaRef":talkingHeadMediaRef,
               "streamId":streamId,
               "useYesNo":useYesNo,
               "customCallback":customCallback,
               "customPassback":customPassback
            });
         }
      }
      
      private static function updateTalkingPopupSize() : void
      {
         with(_talkingPopup)
         {
            bg.m.height = Math.floor(currentFrameLabel == "questingPopup" ? txt.textHeight + (txt.y + (txt.y + 93 + 15)) : Math.max(73.05,txt.textHeight + (txt.y + (txt.y + 93 + 5))));
            bg.b.y = Math.floor(bg.m.y + bg.m.height);
            yesBtn.y = noBtn.y = txt.y + txt.textHeight + yesBtn.height * 0.5 + 5;
            okBtn.y = yesBtn.y + 3;
            nextBtn.y = okBtn.y;
         }
      }
      
      private static function onLevelShapeLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.updateXPShape(param1);
         }
      }
      
      private static function onTalkingDialogLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            _isLoadingTalkingPopup = false;
            _talkingPopup = MovieClip(param1.getChildAt(0));
            _loc2_ = param1.passback;
            showTalkingDialog(_loc2_.popupLayer,_loc2_.fullTextSplit,_loc2_.talkingHeadMediaRef,_loc2_.streamId,_loc2_.useYesNo,_loc2_.customCallback,_loc2_.customPassback);
         }
      }
      
      private static function onTalkingHeadMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_talkingPopup != null)
            {
               _talkingPopup.itemRenderPlaceholder.itemWindow.addChild(param1);
               _talkingLoadingSpiral.visible = false;
            }
         }
      }
      
      private static function onAdventureGoalRewardsLoaded(param1:MovieClip) : void
      {
         if(_questActorDictionary != null && param1)
         {
            _adventureRewardsPopupStatus = [];
            if(_adventureRewardsPopup == null)
            {
               _adventureRewardsPopup = MovieClip(param1.getChildAt(0));
               _adventureRewardsPopup.x = 900 * 0.5;
               _adventureRewardsPopup.y = 550 * 0.5;
               _adventureRewardsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            }
            updateRewardsDisplay(param1.passback);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateRewardsDisplay(param1:Array) : void
      {
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc3_:String = null;
         var _loc2_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         if(_adventureRewardsPopup)
         {
            switch((_loc8_ = getAdventureType()) - 1)
            {
               case 0:
                  _adventureRewardsPopup.setQuestType(2);
                  break;
               case 1:
               case 2:
               case 3:
               case 4:
               case 5:
               case 6:
               case 7:
               case 8:
                  _adventureRewardsPopup.setQuestType(3);
                  break;
               default:
                  _adventureRewardsPopup.setQuestType(1);
            }
            _loc6_ = 1;
            while(_loc6_ <= 5)
            {
               _loc7_ = "gui_goal" + _loc6_;
               _loc3_ = "gui_goal" + _loc6_ + "a";
               _loc2_ = _questActorDictionary[_loc7_];
               _loc4_ = _questActorDictionary[_loc3_];
               if(_loc4_ && _loc2_ && (_loc8_ != 3 && _loc8_ != 6 && _loc8_ != 7 && _loc8_ != 4 && _loc8_ != 5 && _loc8_ != 8 && _loc8_ != 9))
               {
                  _loc5_ = 0;
                  _loc9_ = int(_loc4_.state);
                  switch(_loc8_ - 1)
                  {
                     case 0:
                        _loc5_ = _playerOrbCountTotal;
                        if(_loc6_ == 1 && _loc5_ < _loc9_)
                        {
                           _loc9_ = 0;
                        }
                        break;
                     default:
                        _loc5_ = int(_loc2_.state);
                  }
                  if(_loc2_.hasOwnProperty("prizePicked"))
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc6_] = true;
                     }
                     _adventureRewardsPopup.setState(_loc6_,3);
                     _adventureRewardsPopup["opt" + _loc6_].removeEventListener("mouseDown",onAdventureRewardsOptions);
                  }
                  else if(_loc5_ >= _loc9_ && param1[_loc6_ - 1].type != 0)
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc6_] = false;
                     }
                     _adventureRewardsPopup.setState(_loc6_,2);
                     _adventureRewardsPopup["opt" + _loc6_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                     _adventureRewardsPopup["opt" + _loc6_].index = _loc6_ - 1;
                     _adventureRewardsPopup["opt" + _loc6_].prize = param1[_loc6_ - 1];
                  }
                  else
                  {
                     if(_adventureRewardsPopupStatus != null)
                     {
                        _adventureRewardsPopupStatus[_loc6_] = true;
                     }
                     _adventureRewardsPopup.setState(_loc6_,1);
                  }
                  _adventureRewardsPopup.setValue(_loc6_,_loc5_);
                  _adventureRewardsPopup.setMaxValue(_loc6_,_loc9_);
               }
               else if(_loc8_ == 2 || _loc8_ == 3 || _loc8_ == 6 || _loc8_ == 7 || _loc8_ == 4 || _loc8_ == 5 || _loc8_ == 8 || _loc8_ == 9)
               {
                  switch(_loc6_ - 1)
                  {
                     case 0:
                        if(_adventureRewardsPopupStatus != null)
                        {
                           _adventureRewardsPopupStatus[_loc6_] = false;
                        }
                        switch(_adventureRewardsPopupType - 3)
                        {
                           case 0:
                              _adventureRewardsPopup.setState(_loc6_,14);
                              break;
                           case 1:
                           case 2:
                              _adventureRewardsPopup.setState(_loc6_,20);
                              break;
                           case 3:
                              _adventureRewardsPopup.setState(_loc6_,32);
                              break;
                           default:
                              if(_loc8_ == 7)
                              {
                                 _adventureRewardsPopup.setState(_loc6_,26);
                                 break;
                              }
                              _adventureRewardsPopup.setState(_loc6_,2);
                              break;
                        }
                        _adventureRewardsPopup["opt" + _loc6_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                        _adventureRewardsPopup["opt" + _loc6_].index = _loc6_ - 1;
                        _adventureRewardsPopup["opt" + _loc6_].prize = param1[_loc6_ - 1];
                        break;
                     case 1:
                        if(!gMainFrame.userInfo.isMember)
                        {
                           if(_adventureRewardsPopupStatus != null)
                           {
                              _adventureRewardsPopupStatus[_loc6_] = true;
                           }
                           switch(_adventureRewardsPopupType - 3)
                           {
                              case 0:
                                 _adventureRewardsPopup.setState(_loc6_,16);
                                 break;
                              case 1:
                              case 2:
                                 _adventureRewardsPopup.setState(_loc6_,22);
                                 break;
                              case 3:
                                 _adventureRewardsPopup.setState(_loc6_,34);
                                 break;
                              default:
                                 if(_loc8_ == 7)
                                 {
                                    _adventureRewardsPopup.setState(_loc6_,28);
                                    break;
                                 }
                                 _adventureRewardsPopup.setState(_loc6_,4);
                                 break;
                           }
                           _adventureRewardsPopup["opt" + _loc6_].addEventListener("mouseDown",onAdventureNonMemberRewardsOptions,false,0,true);
                           _adventureRewardsPopup["opt" + _loc6_].index = _loc6_ - 1;
                           _adventureRewardsPopup["opt" + _loc6_].prize = param1[_loc6_ - 1];
                           break;
                        }
                        if(_adventureRewardsPopupStatus != null)
                        {
                           _adventureRewardsPopupStatus[_loc6_] = false;
                        }
                        switch(_adventureRewardsPopupType - 3)
                        {
                           case 0:
                              _adventureRewardsPopup.setState(_loc6_,17);
                              break;
                           case 1:
                           case 2:
                              _adventureRewardsPopup.setState(_loc6_,23);
                              break;
                           case 3:
                              _adventureRewardsPopup.setState(_loc6_,35);
                              break;
                           default:
                              if(_loc8_ == 7)
                              {
                                 _adventureRewardsPopup.setState(_loc6_,29);
                                 break;
                              }
                              _adventureRewardsPopup.setState(_loc6_,5);
                              break;
                        }
                        _adventureRewardsPopup["opt" + _loc6_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
                        _adventureRewardsPopup["opt" + _loc6_].index = _loc6_ - 1;
                        _adventureRewardsPopup["opt" + _loc6_].prize = param1[_loc6_ - 1];
                        break;
                  }
               }
               else
               {
                  _adventureRewardsPopup.setState(_loc6_,1);
                  _adventureRewardsPopup.setValue(0,0);
                  _adventureRewardsPopup.setMaxValue(_loc6_,0);
               }
               _loc6_++;
            }
         }
      }
      
      private static function onAdventureRewardsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _adventureRewardsPopup = MovieClip(param1.getChildAt(0));
            _adventureRewardsPopup.x = 900 * 0.5;
            _adventureRewardsPopup.y = 550 * 0.5;
            updateAdventureRewards(param1.passback);
            _adventureRewardsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            GuiManager.guiLayer.addChild(_adventureRewardsPopup);
            DarkenManager.darken(_adventureRewardsPopup);
         }
      }
      
      private static function updateAdventureRewards(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(_adventureRewardsPopup)
         {
            _loc2_ = 1;
            while(_loc2_ <= 5)
            {
               _adventureRewardsPopup["opt" + _loc2_].addEventListener("mouseDown",onAdventureRewardsOptions,false,0,true);
               _adventureRewardsPopup["opt" + _loc2_].index = _loc2_ - 1;
               _adventureRewardsPopup["opt" + _loc2_].prize = param1[_loc2_ - 1];
               _loc2_++;
            }
         }
      }
      
      private static function onAdventureNonMemberRewardsOptions(param1:MouseEvent) : void
      {
         UpsellManager.displayPopup("adventures","adventure/" + _questScriptDefId);
      }
      
      private static function onAdventureRewardsOptions(param1:MouseEvent) : void
      {
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc3_:Object = null;
         var _loc9_:int = getAdventureType();
         _adventureRewardsPopup.giftIndexChosen = param1.currentTarget.index;
         if(_adventureGoals || _loc9_ == 2 || _loc9_ == 3 || _loc9_ == 6 || _loc9_ == 7 || _loc9_ == 5 || _loc9_ == 4 || _loc9_ == 8 || _loc9_ == 9)
         {
            _loc4_ = _adventureRewardsPopup.giftIndexChosen + 1;
            _loc5_ = "gui_goal" + _loc4_;
            _loc3_ = _questActorDictionary[_loc5_];
            if(_loc3_)
            {
               _loc3_.prizePicked = true;
            }
            if(_adventureRewardsPopup)
            {
               if(_adventureRewardsPopupStatus != null)
               {
                  _adventureRewardsPopupStatus[_loc4_] = true;
               }
               switch(_adventureRewardsPopupType - 3)
               {
                  case 0:
                     if(_loc4_ == 2)
                     {
                        _adventureRewardsPopup.setState(_loc4_,18);
                        break;
                     }
                     _adventureRewardsPopup.setState(_loc4_,15);
                     break;
                  case 1:
                  case 2:
                     if(_loc4_ == 2)
                     {
                        _adventureRewardsPopup.setState(_loc4_,24);
                        break;
                     }
                     _adventureRewardsPopup.setState(_loc4_,21);
                     break;
                  case 3:
                     if(_loc4_ == 2)
                     {
                        _adventureRewardsPopup.setState(_loc4_,36);
                        break;
                     }
                     _adventureRewardsPopup.setState(_loc4_,33);
                     break;
                  default:
                     if(_loc9_ == 7)
                     {
                        if(_loc4_ == 2)
                        {
                           _adventureRewardsPopup.setState(_loc4_,30);
                           break;
                        }
                        _adventureRewardsPopup.setState(_loc4_,27);
                        break;
                     }
                     if(_loc4_ == 2)
                     {
                        _adventureRewardsPopup.setState(_loc4_,6);
                        break;
                     }
                     _adventureRewardsPopup.setState(_loc4_,3);
                     break;
               }
               _adventureRewardsPopup["opt" + _loc4_].removeEventListener("mouseDown",onAdventureRewardsOptions);
            }
         }
         switch(param1.currentTarget.prize.type)
         {
            case 1:
               _loc6_ = new DenItem();
               (_loc6_ as DenItem).initShopItem(param1.currentTarget.prize.defID,param1.currentTarget.prize.versionId);
               _loc7_ = 2;
               _loc2_ = int(_loc6_.defId);
               break;
            case 2:
               _loc6_ = new Item();
               (_loc6_ as Item).init(param1.currentTarget.prize.defID,0,param1.currentTarget.prize.color,null,true);
               _loc7_ = 1;
               _loc2_ = int(_loc6_.defId);
               break;
            default:
               break;
            case 3:
               _loc7_ = 0;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(1086,rewardsGemOrCrystalLoaded,{
                  "giftType":_loc7_,
                  "amount":LocalizationManager.translateIdAndInsertOnly(11097,param1.currentTarget.prize.amount)
               });
               return;
            case 4:
               _loc7_ = 7;
               DarkenManager.showLoadingSpiral(true);
               _mediaLoader = new MediaHelper();
               _mediaLoader.init(2221,rewardsGemOrCrystalLoaded,{
                  "giftType":_loc7_,
                  "amount":LocalizationManager.translateIdAndInsertOnly(11117,param1.currentTarget.prize.amount)
               });
               return;
         }
         _rewardsGiftPopup = new GiftPopup();
         var _loc8_:int = 8;
         loop2:
         switch(_adventureRewardsPopupType - 3)
         {
            case 0:
               _loc8_ = 15;
               break;
            case 1:
            case 2:
               _loc8_ = 16;
               break;
            case 3:
               _loc8_ = 19;
               break;
            default:
               switch(_loc9_ - 2)
               {
                  case 0:
                  case 1:
                  case 2:
                     _loc8_ = 14;
                     break loop2;
                  case 5:
                     _loc8_ = 17;
                     break loop2;
                  default:
                     _loc8_ = 8;
               }
         }
         _rewardsGiftPopup.init(GuiManager.guiLayer,_loc6_.largeIcon,_loc6_.name,_loc2_,_loc8_,_loc7_,onKeepRewardsGift,onDiscardRewardsGift,null,false,0);
      }
      
      private static function rewardsGemOrCrystalLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _rewardsGiftPopup = new GiftPopup();
         switch(_adventureRewardsPopupType - 6)
         {
            case 0:
               _rewardsGiftPopup.init(GuiManager.guiLayer,param1,param1.passback.amount,0,19,param1.passback.giftType,onKeepRewardsGift,onKeepRewardsGift,null,false,1);
               break;
            default:
               _rewardsGiftPopup.init(GuiManager.guiLayer,param1,param1.passback.amount,0,8,param1.passback.giftType,onKeepRewardsGift,onKeepRewardsGift,null,false,1);
         }
      }
      
      private static function onDiscardRewardsGift() : void
      {
         QuestXtCommManager.sendPickGiftResult(-1,false,true);
         removeGiftPopup();
      }
      
      private static function onKeepRewardsGift() : void
      {
         var _loc1_:Object = _questActorDictionary["gui_goal1a"];
         if((getAdventureType() == 1 || getAdventureType() == 4) && _loc1_ != null && _playerOrbCountTotal < _loc1_.state)
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,true,false);
         }
         else
         {
            QuestXtCommManager.sendPickGiftResult(_adventureRewardsPopup.giftIndexChosen,false,false);
         }
         removeGiftPopup();
      }
      
      private static function removeGiftPopup() : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc3_:String = null;
         var _loc2_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         _rewardsGiftPopup.destroy();
         _rewardsGiftPopup = null;
         var _loc1_:Boolean = true;
         var _loc9_:int = getAdventureType();
         if(_adventureGoals && _loc9_ != 5 && _loc9_ != 3 && _loc9_ != 6 && _loc9_ != 7 && _loc9_ != 4 && _loc9_ != 8 && _loc9_ != 9)
         {
            _loc6_ = 1;
            while(_loc6_ <= 5)
            {
               _loc7_ = "gui_goal" + _loc6_;
               _loc3_ = "gui_goal" + _loc6_ + "a";
               _loc2_ = _questActorDictionary[_loc7_];
               _loc4_ = _questActorDictionary[_loc3_];
               if(_loc2_ && _loc4_)
               {
                  _loc5_ = 0;
                  _loc10_ = int(_loc4_.state);
                  switch(_loc9_ - 1)
                  {
                     case 0:
                     case 3:
                        _loc5_ = _playerOrbCountTotal;
                        break;
                     default:
                        _loc5_ = int(_loc2_.state);
                  }
                  if(_loc5_ >= _loc10_ && !_loc2_.hasOwnProperty("prizePicked"))
                  {
                     _loc1_ = false;
                     break;
                  }
               }
               _loc6_++;
            }
         }
         else if(_loc9_ == 2 || _loc9_ == 3 || _loc9_ == 6 || _loc9_ == 7 || _loc9_ == 5 || _loc9_ == 4 || _loc9_ == 8 || _loc9_ == 9)
         {
            if(_adventureRewardsPopupStatus != null && _adventureRewardsPopupStatus[1] == false || _adventureRewardsPopupStatus[2] == false)
            {
               _loc1_ = false;
            }
         }
         if(_loc1_)
         {
            _adventureRewardsPopup.removeEventListener("mouseDown",onPopup);
            _loc8_ = 1;
            while(_loc8_ <= 5)
            {
               _adventureRewardsPopup["opt" + _loc8_].removeEventListener("mouseDown",onAdventureRewardsOptions);
               _loc8_++;
            }
            DarkenManager.unDarken(_adventureRewardsPopup);
            GuiManager.guiLayer.removeChild(_adventureRewardsPopup);
            _adventureRewardsPopup = null;
            QuestXtCommManager.sendPickGiftComplete();
         }
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onTalkingPopupClose(param1:MouseEvent) : void
      {
         if(param1 != null)
         {
            param1.stopPropagation();
         }
         if(_talkingPopup)
         {
            _talkingPopup.removeEventListener("mouseDown",onPopup);
            _talkingPopup.bx.removeEventListener("mouseDown",onTalkingPopupClose);
            if(_talkingPopup.currentFrameLabel == "response")
            {
               _talkingPopup.yesBtn.removeEventListener("mouseDown",onYesBtn);
               _talkingPopup.noBtn.removeEventListener("mouseDown",onNoBtn);
            }
            else if(_talkingPopup.currentFrameLabel == "ok")
            {
               _talkingPopup.okBtn.removeEventListener("mouseDown",onOkBtn);
            }
            _talkingPopup.parent.removeChild(_talkingPopup);
            DarkenManager.unDarken(_talkingPopup);
            if(_talkingPopup.customCallback == null)
            {
               onCommandAskConfirm(true);
            }
            _talkingPopup = null;
         }
      }
      
      private static function onConfirmBtn(param1:Object) : void
      {
         onCommandAskConfirm(param1.status);
      }
      
      private static function onYesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.customCallback != null)
         {
            param1.currentTarget.parent.customCallback(param1.currentTarget.parent.customPassback);
         }
         else
         {
            onCommandAskConfirm(true);
         }
         onTalkingPopupClose(param1);
      }
      
      private static function onNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.customCallback == null)
         {
            onCommandAskConfirm(false);
         }
         onTalkingPopupClose(param1);
      }
      
      private static function onOkBtn(param1:MouseEvent) : void
      {
         if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
         {
            onTalkingPopupClose(param1);
            return;
         }
         if(_talkingPopup)
         {
            _talkingPopupCurrTextPage++;
            _talkingPopup.txt.text = _talkingPopupFullText[_talkingPopupCurrTextPage];
            if(_talkingPopupCurrTextPage + 1 > _talkingPopupFullText.length - 1)
            {
               _talkingPopup.nextBtn.visible = false;
               if(_talkingPopup.useYesNo)
               {
                  _talkingPopup.yesBtn.visible = true;
                  _talkingPopup.noBtn.visible = true;
                  _talkingPopup.okBtn.visible = false;
                  _talkingPopup.nextBtn.visible = false;
               }
               else
               {
                  _talkingPopup.okBtn.visible = true;
               }
            }
            else
            {
               _talkingPopup.okBtn.visible = false;
               _talkingPopup.nextBtn.visible = true;
            }
            updateTalkingPopupSize();
         }
      }
      
      public static function handleQuestStartResponse(param1:Object) : void
      {
         var _loc2_:int = 2;
         _questScriptDefId = param1[_loc2_++];
         _questStartingPlayerCount = param1[_loc2_++];
         _questSeeds = new Dictionary();
         if(_seedInventory != null)
         {
            _seedInventory.destroy();
            _seedInventory = null;
         }
         _questObjectiveText = "";
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#NumPlayers/" + _questStartingPlayerCount);
         SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#Difficulty/" + _questDifficultyLevel);
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
            AvatarManager.resetCustomAdventureState();
         }
         _roomManager.setGridDepth(25);
      }
      
      public static function handleQuestWaitResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.handleWaitResponse(param1);
         }
         if(_privateAdventureJoin)
         {
            _privateAdventureJoin.handleWaitResponse(param1);
         }
      }
      
      public static function handleQuestJoinCancelResponse(param1:Object) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      public static function handleQuestJoinResponse(param1:Object, param2:String, param3:int = 0) : void
      {
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(param2 == "custSettings")
         {
            if(_adventureJoin)
            {
               _adventureJoin.destroy();
               _adventureJoin = null;
            }
            if(_privateAdventureJoin)
            {
               _privateAdventureJoin.destroy();
               _privateAdventureJoin = null;
            }
            _privateAdventureJoin = new PrivateAdventureJoin();
            _privateAdventureJoin.init(param1[4],privateAdventureJoinClose);
            UserCommXtCommManager.sendCustomAdventureMessage(true);
         }
         else
         {
            openAdventureJoin(param1[4],param2,param3);
         }
      }
      
      public static function openAdventureJoin(param1:int, param2:String, param3:int) : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
         }
         _adventureJoin = new AdventureJoin();
         _adventureJoin.init(param1,param2,param3,adventureJoinClose);
      }
      
      public static function get isInPrivateAdventureState() : Boolean
      {
         return _privateAdventureJoin != null;
      }
      
      public static function isBeYourPetQuest() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _loc1_ = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc1_ != null && _loc1_.playAsPet)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function isDynamicallyJoinableQuest() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _loc1_ = QuestXtCommManager.getScriptDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc1_ != null && _loc1_.time == 1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function updatePrivateAdventureIndexComparedToMainHud() : void
      {
         if(_privateAdventureJoin)
         {
            _privateAdventureJoin.updateDisplayIndex();
         }
      }
      
      public static function handleAttackPlayer(param1:Object) : void
      {
         var _loc4_:QuestActor = null;
         var _loc2_:String = null;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 2;
         _loc2_ = param1[_loc6_++];
         _loc4_ = _questActorsDict[_loc2_];
         if(_loc4_ != null)
         {
            _loc7_ = int(param1[_loc6_++]);
            _loc3_ = int(param1[_loc6_++]);
            _loc5_ = uint(param1[_loc6_++]);
            _loc4_.handleAttackPlayer(_loc3_,_loc5_,_loc7_);
         }
      }
      
      public static function handleQuestActorPositionUpdateResponse(param1:Object) : void
      {
         var _loc6_:QuestActor = null;
         var _loc4_:String = null;
         var _loc10_:int = 2;
         _loc4_ = param1[_loc10_++];
         var _loc2_:int = int(param1[_loc10_++]);
         var _loc8_:int = int(param1[_loc10_++]);
         var _loc5_:int = int(param1[_loc10_++]);
         var _loc3_:int = int(param1[_loc10_++]);
         var _loc9_:int = int(param1[_loc10_++]);
         var _loc11_:int = int(param1[_loc10_++]);
         var _loc7_:Object = _questActorDictionary[_loc4_];
         if(_loc7_ != null)
         {
            _loc7_.actorPos = new Point(_loc2_,_loc8_);
         }
         _loc6_ = _questActorsDict[_loc4_];
         if(_loc6_ != null)
         {
            _loc6_.handlePositionUpdate(_loc2_,_loc8_,_loc5_,_loc3_,_loc9_,_loc11_);
         }
      }
      
      public static function setQuestActorSeek(param1:QuestActor, param2:int) : void
      {
         if(param2 > param1._actorData.seekType || AvatarManager.playerSfsUserId == param1._actorData.seekTypeSfsId)
         {
            QuestXtCommManager.questActorSeek(param1._actorId,param2);
         }
      }
      
      public static function handleQuestActorRequestSeekResponse(param1:Object) : void
      {
         var _loc4_:QuestActor = null;
         var _loc3_:String = null;
         var _loc6_:int = 2;
         _loc3_ = param1[_loc6_++];
         var _loc2_:int = int(param1[_loc6_++]);
         var _loc7_:int = int(param1[_loc6_++]);
         var _loc5_:Object = _questActorDictionary[_loc3_];
         if(_loc5_ != null)
         {
            if(_loc2_ > _loc5_.seekType || _loc7_ == _loc5_.seekTypeSfsId)
            {
               _loc5_.seekType = _loc2_;
               _loc5_.seekTypeSfsId = _loc7_;
            }
         }
         if(_loc7_ == AvatarManager.playerSfsUserId)
         {
            _loc4_ = _questActorsDict[_loc3_];
            if(_loc4_ != null)
            {
               _loc4_.handleRequestSeekResponse(_loc2_);
            }
         }
      }
      
      public static function handleLaunchProjectile(param1:Object) : void
      {
         var _loc8_:AvatarWorldView = null;
         var _loc10_:int = 2;
         var _loc3_:int = int(param1[_loc10_++]);
         var _loc9_:int = int(param1[_loc10_++]);
         var _loc6_:int = int(param1[_loc10_++]);
         var _loc4_:String = param1[_loc10_++];
         var _loc5_:int = int(param1[_loc10_++]);
         var _loc2_:uint = uint(param1[_loc10_++]);
         var _loc7_:QuestActor = null;
         if(_loc5_ > 0)
         {
            _loc8_ = AvatarManager.avatarViewList[_loc5_];
            if(_loc8_ == null)
            {
               return;
            }
            _loc8_.faceAnim(_loc9_ - _loc8_.avatarPos.x,_loc6_ - _loc8_.avatarPos.y,false);
         }
         else
         {
            _loc7_ = _questActorsDict[_loc4_];
         }
         launchProjectile(_loc3_,_loc2_,_loc9_,_loc6_,_loc7_,_loc8_);
      }
      
      public static function handleSetSwfState(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc5_:Object = null;
         var _loc3_:QuestActor = null;
         if(_questActorDictionary != null)
         {
            _loc6_ = 2;
            _loc4_ = param1[_loc6_++];
            _loc2_ = param1[_loc6_++];
            _loc5_ = _questActorDictionary[_loc4_];
            if(_loc5_ != null)
            {
               if(_loc5_.pendingSwfStateName == null)
               {
                  _loc5_.pendingSwfStateName = [];
               }
               _loc5_.pendingSwfStateName.push(_loc2_);
               _loc5_.onReinitSwfStateName = _loc2_;
            }
            _loc3_ = _questActorsDict[_loc4_];
            if(_loc3_ != null)
            {
               _loc3_.setSwfState(_loc2_);
            }
         }
      }
      
      public static function handleLoadMediaLib(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:int = int(param1[_loc3_++]);
         loadQuestSfx(_loc2_);
      }
      
      public static function getMaxQuestGoal(param1:int) : int
      {
         switch(param1 - 1)
         {
            case 0:
            case 6:
            case 7:
            case 8:
               return 5;
            case 4:
               return 1;
            default:
               return 4;
         }
      }
      
      public static function handleOrbsUpdate(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc9_:int = 2;
         var _loc7_:int;
         _playerCrystalCount = _loc7_ = int(param1[_loc9_++]);
         if(_playerOrbCountTotal < _playerCrystalCount)
         {
            _loc6_ = _playerOrbCountTotal;
            _playerOrbCountTotal = _playerCrystalCount;
            if(_adventureGoals != null)
            {
               loop1:
               switch((_loc8_ = getAdventureType()) - 1)
               {
                  case 0:
                  case 2:
                  case 3:
                  case 4:
                  case 5:
                  case 6:
                  case 7:
                  case 8:
                     if(_questActorDictionary["gui_goal1"])
                     {
                        if(_adventureGoals[1])
                        {
                           _loc5_ = getMaxQuestGoal(_loc8_);
                           _loc4_ = 1;
                           while(true)
                           {
                              if(_loc4_ > _loc5_)
                              {
                                 break loop1;
                              }
                              _loc2_ = "gui_goal" + _loc4_ + "a";
                              _loc3_ = _questActorDictionary[_loc2_];
                              if(_loc3_ != null && _loc6_ < _loc3_.state && _playerOrbCountTotal >= _loc3_.state)
                              {
                                 _adventureGoals[1].setGoalAchieved(_loc4_);
                                 if(_loc8_ == 3 || _loc8_ == 6 || _loc8_ == 7 || _loc8_ == 4 || _loc8_ == 5 || _loc8_ == 8 || _loc8_ == 9)
                                 {
                                    QuestXtCommManager.questActorTriggered("gui_goal" + _loc4_);
                                 }
                              }
                              _loc4_++;
                           }
                        }
                        break;
                     }
               }
            }
         }
      }
      
      public static function handlePickUpItem(param1:Object) : void
      {
         var _loc10_:String = null;
         var _loc8_:String = null;
         var _loc3_:Object = null;
         var _loc9_:int = 0;
         var _loc4_:Point = null;
         var _loc13_:String = null;
         var _loc14_:int = 0;
         var _loc2_:int = 0;
         var _loc15_:int = 0;
         var _loc11_:Boolean = false;
         var _loc12_:QuestActor = null;
         var _loc6_:int = 0;
         var _loc5_:int = 2;
         var _loc7_:int;
         switch(_loc7_ = int(param1[_loc5_++]))
         {
            case 0:
               if(allowItemDrop())
               {
                  _loc10_ = param1[_loc5_++];
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14812),true,onDropItemConfirm,_loc10_);
                  playSound("ajq_itemAlert");
                  break;
               }
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(21617));
               break;
            case 1:
            case 3:
            case 4:
               _loc8_ = param1[_loc5_++];
               _loc3_ = _questActorDictionary[_loc8_];
               _loc9_ = int(param1[_loc5_++]);
               if(_loc7_ == 4 || _loc7_ == 3)
               {
                  _loc4_ = new Point(param1[_loc5_++],param1[_loc5_++]);
                  if(_loc7_ == 4)
                  {
                     _loc14_ = int(param1[_loc5_++]);
                     _loc2_ = int(param1[_loc5_++]);
                     _loc15_ = int(param1[_loc5_++]);
                     if(_loc15_ == AvatarManager.playerSfsUserId)
                     {
                        _loc13_ = param1[_loc5_++];
                     }
                  }
               }
               if(_loc3_ != null)
               {
                  if(_loc3_.type == 15)
                  {
                     _loc3_.previouslyPickedUp = true;
                  }
                  _loc11_ = _loc7_ == 4 || _loc7_ == 3 || _loc3_.type == 17;
                  if(_loc4_ != null && _loc3_.type != 17)
                  {
                     _loc3_.actorPos = _loc4_;
                  }
                  _loc3_.visible = _loc11_;
                  _loc12_ = _questActorsDict[_loc8_];
                  if(_loc12_ != null)
                  {
                     if(_loc4_ != null && _loc3_.type != 17)
                     {
                        _loc12_.x = _loc4_.x;
                        _loc12_.y = _loc4_.y;
                     }
                     _loc12_.setVisible(_loc11_);
                     if(_loc9_ == AvatarManager.playerSfsUserId && _loc7_ != 4)
                     {
                        _loc6_ = int(_loc7_ == 4 || _loc7_ == 3 ? 0 : UserCommXtCommManager.getEmoticonDefId(_loc12_._actorData.defId));
                        AvatarManager.setPlayerAttachmentEmot(_loc6_,null,0);
                        AvatarManager._setAvatarAttachmentEmot(_loc7_ == 4 || _loc7_ == 3 ? 0 : _loc12_._actorData.defId,"",_loc9_);
                        if(_loc12_._mediaObject && _loc12_._mediaObject.hasOwnProperty("playPickupSound"))
                        {
                           _loc12_._mediaObject.playPickupSound();
                        }
                     }
                     break;
                  }
                  if(_loc7_ == 4)
                  {
                     initQuestActor(_loc8_,_loc14_,_loc2_,null,new Point(_loc4_.x,_loc4_.y));
                  }
               }
               break;
            case 2:
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14813));
         }
      }
      
      public static function handleMovedItemList(param1:Array) : void
      {
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Point = null;
         var _loc6_:int = 2;
         while(_loc6_ < param1.length)
         {
            _loc4_ = param1[_loc6_++];
            _loc5_ = int(param1[_loc6_++]);
            _loc2_ = int(param1[_loc6_++]);
            _loc3_ = new Point(param1[_loc6_++],param1[_loc6_++]);
            if(_questActorsDict[_loc4_])
            {
               _loc6_ += 2;
            }
            else
            {
               initQuestActor(_loc4_,_loc5_,_loc2_,null,_loc3_);
            }
         }
      }
      
      public static function handleStatsUpdate(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(_loc2_ != null)
         {
            _loc2_.attackBase = param1[_loc3_++];
            _loc2_.attackMax = param1[_loc3_++];
            _loc2_.defenseBase = param1[_loc3_++];
            _loc2_.defenseMax = param1[_loc3_++];
            gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myPerUserAvId,_loc2_);
         }
      }
      
      public static function handleLevelUp(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc2_:int = int(param1[_loc3_++]);
         var _loc5_:QuestPlayerData = getQuestPlayerData(_loc4_);
         if(_loc5_ != null)
         {
            _loc5_.levelUp(_loc2_);
         }
      }
      
      public static function handleXpUpdate(param1:Object) : void
      {
         var _loc7_:Object = null;
         var _loc11_:int = 2;
         var _loc4_:int = int(param1[_loc11_++]);
         var _loc8_:int = int(param1[_loc11_++]);
         var _loc2_:int = int(param1[_loc11_++]);
         var _loc3_:int = int(param1[_loc11_++]);
         var _loc6_:Number = Number(param1[_loc11_++]);
         var _loc10_:String = param1[_loc11_++];
         var _loc9_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         _totalXPEarned += _loc4_;
         _loc9_.questXp = _loc8_;
         _loc9_.questLevel = _loc3_;
         _loc9_.questXPPercentage = _loc6_;
         GuiManager.addQuestXP(_loc6_);
         var _loc5_:QuestActor = _questActorsDict[_loc10_];
         if(_loc5_ != null)
         {
            _loc5_.setActorText(LocalizationManager.translateIdAndInsertOnly(18481,_loc4_));
         }
         if(_loc2_ < _loc3_)
         {
            _loc7_ = QuestXtCommManager.getScriptDef(_questScriptDefId);
            if(_loc7_ && _loc7_.levelMin == 0)
            {
               gMainFrame.userInfo.updateAllAvatarInfoQuestXPIfZeroByUserName(gMainFrame.userInfo.myUserName,_loc8_,_loc3_);
            }
            SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#levelUp/" + _loc3_);
            if(_loc3_ % 5 == 0)
            {
               loadLevelShape(_loc3_);
            }
            else
            {
               GuiManager.updateShapeXP(_loc3_);
            }
            if(AvatarManager.playerAvatarWorldView)
            {
               AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(_loc3_);
            }
         }
      }
      
      public static function handleQuestActorTriggerTreasure(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 2;
         var _loc7_:String = param1[_loc8_++];
         var _loc5_:QuestActor = _questActorsDict[_loc7_];
         if(_loc5_ != null)
         {
            _loc2_ = int(param1[_loc8_++]);
            _loc4_ = int(param1[_loc8_++]);
            _loc6_ = int(param1[_loc8_++]);
            _loc3_ = int(param1[_loc8_++]);
            _loc5_.handleTriggerTreasure(_loc2_,_loc4_,_loc6_,_loc3_);
         }
      }
      
      public static function handleRestore(param1:Object) : void
      {
         var _loc7_:int = 0;
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc6_:Object = null;
         var _loc3_:QuestActor = null;
         var _loc4_:int = 0;
         if(_questActorDictionary != null)
         {
            _loc7_ = 2;
            _loc5_ = param1[_loc7_++];
            _loc2_ = int(param1[_loc7_++]);
            _loc6_ = _questActorDictionary[_loc5_];
            if(_loc6_ != null && Boolean(_loc6_.hasOwnProperty("actorPos")))
            {
               _loc6_.healthPercent = _loc2_;
               if(_loc6_.type == 11)
               {
                  if(_loc6_.hasOwnProperty("actorOrigPos"))
                  {
                     _loc6_.actorPos = new Point(_loc6_.actorOrigPos.x,_loc6_.actorOrigPos.y);
                  }
                  else
                  {
                     _loc6_.actorPos = new Point(0,0);
                  }
                  _loc6_.seekType = 0;
                  _loc6_.seekTypeSfsId = 0;
               }
               _loc3_ = _questActorsDict[_loc5_];
               if(_loc3_ != null)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _questActors.length)
                  {
                     if(_questActors[_loc4_]._actorId == _loc5_)
                     {
                        _questActors.splice(_loc4_,1);
                        break;
                     }
                     _loc4_++;
                  }
                  _questActorsDict[_loc5_].destroy();
                  delete _questActorsDict[_loc5_];
               }
               _loc3_ = new QuestActor();
               _loc3_.initActor(_loc5_,_loc6_,_loc6_.origInnerRadius,_loc6_.origOuterRadius,_loc6_.origPriority,null);
               _loc3_.setRequireClick(_loc6_.requireClick);
               _loc3_.setVisible(_loc6_.visible);
               _questActors.push(_loc3_);
               _questActorsDict[_loc5_] = _loc3_;
               if(_loc3_ != null)
               {
                  _loc3_.healthUpdate(_loc2_,0,false);
               }
            }
         }
      }
      
      public static function handleAvSwitch(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc2_:int = int(param1[_loc4_++]);
         if(_loc3_ != -1)
         {
            if(_questPlayersSwitched == null)
            {
               _questPlayersSwitched = new Dictionary();
            }
            _questPlayersSwitched[_loc2_] = _loc3_;
         }
         else if(_questPlayersSwitched != null && _questPlayersSwitched[_loc2_] != null)
         {
            delete _questPlayersSwitched[_loc2_];
         }
         var _loc5_:QuestPlayerData = getQuestPlayerData(_loc2_);
         if(_loc5_ != null)
         {
            _loc5_.setAvatarSwitched(_loc3_);
         }
      }
      
      public static function handleExitByType(param1:Object) : void
      {
         var _loc3_:int = 2;
         var _loc2_:String = param1[_loc3_++];
         if(_loc2_ == "ffm")
         {
            GuiManager.isInFFM = false;
            LoadProgress.show(true);
            GuiManager.updateMainHudButtons(false,{
               "btnName":(GuiManager.mainHud as GuiHud).money.name,
               "show":true
            },{
               "btnName":(GuiManager.mainHud as GuiHud).eCardBtn.name,
               "show":true
            },{
               "btnName":(GuiManager.mainHud as GuiHud).buddyListBtn.name,
               "show":true
            },{
               "btnName":(GuiManager.mainHud as GuiHud).games.name,
               "show":true
            },{
               "btnName":(GuiManager.mainHud as GuiHud).partyBtn.name,
               "show":true
            });
            if(gMainFrame.clientInfo.dbUserId % 32 != 0)
            {
               onExitRoom();
               DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
               GuiManager.setupInGameRedemptions();
            }
            else
            {
               _roomManager.setGotoSpawnPoint("ff1");
               RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_main#" + _roomManager.shardId);
               SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,1);
               GuiManager.initPlayerEngagement(null);
            }
         }
         else if(_loc2_ == "flag")
         {
            RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#-1");
         }
      }
      
      public static function handleSpawn(param1:Object) : void
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:int = 0;
         var _loc14_:Object = null;
         var _loc6_:int = 2;
         var _loc4_:String = param1[_loc6_++];
         var _loc5_:String = param1[_loc6_++];
         var _loc3_:int = int(param1[_loc6_++]);
         var _loc8_:int = int(param1[_loc6_++]);
         var _loc11_:Object = {};
         _loc11_.visible = true;
         _loc11_.requireClick = true;
         _loc11_.type = _loc3_;
         _loc11_.defId = _loc8_;
         _loc11_.state = 0;
         _loc11_.actorName = _loc5_;
         initInitialActorStatus(_loc11_,_loc4_);
         loop0:
         switch(_loc3_)
         {
            case 200:
               _loc12_ = int(param1[_loc6_++]);
               _loc11_.subType = _loc12_;
               switch(_loc12_ - 1)
               {
                  case 0:
                     _loc13_ = int(param1[_loc6_++]);
                     _loc11_.denDefId = _loc13_;
                     break loop0;
                  case 1:
                     _loc7_ = int(param1[_loc6_++]);
                     _loc10_ = int(param1[_loc6_++]);
                     _loc11_.defId = _loc7_;
                     _loc11_.itemData = _loc10_;
                     break loop0;
                  case 2:
                     _loc9_ = int(param1[_loc6_++]);
                     _loc11_.gems = _loc9_;
                     break loop0;
                  case 3:
                     _loc2_ = int(param1[_loc6_++]);
                     _loc14_ = _questActorDictionary["orbnpcid"];
                     _loc11_.gems = _loc2_;
                     if(_loc14_ != null && _loc14_.state != 0)
                     {
                        _loc11_.defId = _loc14_.state;
                        break;
                     }
               }
               break;
            case 11:
            case 23:
               _loc11_.spawnOffsetX = param1[_loc6_++];
               _loc11_.spawnOffsetY = param1[_loc6_++];
         }
         _questActorDictionary[_loc5_] = _loc11_;
         doSpawn(_loc11_,_loc4_);
      }
      
      public static function doSpawnToRoot(param1:Object) : void
      {
         var _loc3_:QuestActor = null;
         var _loc2_:Object = null;
         if(param1.spawnedFromActor != null)
         {
            if(param1.type == 200 && param1.pickedUp == true)
            {
               return;
            }
            _loc3_ = _questActorsDict[param1.spawnedFromActor];
            if(_loc3_ == null)
            {
               _loc2_ = _questActorDictionary[param1.spawnedFromActor];
               if(_loc2_ != null && _loc2_.spawnedFromActor != null)
               {
                  doSpawnToRoot(_loc2_);
               }
            }
            doSpawn(param1,param1.spawnedFromActor);
         }
      }
      
      public static function doSpawn(param1:Object, param2:String) : void
      {
         var _loc15_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Point = null;
         var _loc9_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Array = null;
         var _loc5_:* = NaN;
         var _loc11_:* = NaN;
         var _loc13_:Array = null;
         var _loc7_:int = 0;
         var _loc16_:Number = NaN;
         var _loc14_:QuestActor = _questActorsDict[param1.spawnedFromActor];
         if(_loc14_ != null)
         {
            _loc15_ = 0;
            _loc3_ = 0;
            _loc6_ = null;
            if(param1.actorPos == null)
            {
               _loc9_ = _loc14_.x;
               _loc4_ = _loc14_.y;
               switch(param1.type)
               {
                  case 11:
                  case 23:
                     if(_loc14_._actorData.type == 12)
                     {
                        _loc12_ = 2 * _loc14_._actorDefaultInnerRadius * param1.spawnOffsetX / 1000 - _loc14_._actorDefaultInnerRadius;
                        _loc8_ = 2 * _loc14_._actorDefaultInnerRadius * param1.spawnOffsetY / 1000 - _loc14_._actorDefaultInnerRadius;
                        _loc9_ += _loc12_;
                        _loc4_ += _loc8_;
                        _loc6_ = new Point(-_loc12_,-_loc8_);
                     }
                     break;
                  case 200:
                     if(_loc14_._actorData.type == 11 && _loc14_._actorData.extendedParameters != null)
                     {
                        _loc10_ = _loc14_._actorData.extendedParameters.split(",");
                        _loc5_ = 0;
                        _loc11_ = 0;
                        _loc7_ = 0;
                        while(_loc7_ < _loc10_.length)
                        {
                           switch((_loc13_ = _loc10_[_loc7_].split("="))[0])
                           {
                              case "dropmin":
                                 _loc5_ = Number(_loc13_[1]);
                                 break;
                              case "dropmax":
                                 _loc11_ = Number(_loc13_[1]);
                           }
                           _loc7_++;
                        }
                        if(_loc11_ < _loc5_)
                        {
                           _loc11_ = _loc5_;
                        }
                        else if(_loc5_ > _loc11_)
                        {
                           _loc5_ = _loc11_;
                        }
                        _loc16_ = _loc5_ + Math.random() * (_loc11_ - _loc5_);
                        _loc9_ += Math.random() > 0.5 ? _loc16_ : -_loc16_;
                        _loc4_ += Math.random() > 0.5 ? _loc16_ : -_loc16_;
                        if(_roomManager.collisionTestGrid(_loc9_,_loc4_) != 0)
                        {
                           _loc9_ = _loc14_.x;
                           _loc4_ = _loc14_.y;
                        }
                        break;
                     }
               }
               param1.actorPos = new Point(_loc9_,_loc4_);
               initQuestActor(param1.actorName,_loc15_,_loc3_,param1,null,_loc6_);
            }
            switch(param1.type)
            {
               case 11:
               case 23:
                  param1.respawned = true;
                  if(_loc14_._actorData.type == 12)
                  {
                     _loc15_ = 225;
                     _loc3_ = _loc14_._actorDefaultOuterRadius;
                     break;
                  }
            }
            initQuestActor(param1.actorName,_loc15_,_loc3_,param1,null,_loc6_);
         }
      }
      
      public static function loadLevelShape(param1:int) : void
      {
         var _loc2_:int = 0;
         if(!GuiManager.isBeYourPetRoom())
         {
            _levelShapeHelper = new MediaHelper();
            _loc2_ = int(Math.floor(param1 / 5) > NameBar.LEVEL_SHAPES.length - 1 ? NameBar.LEVEL_SHAPES[NameBar.LEVEL_SHAPES.length - 1] : NameBar.LEVEL_SHAPES[Math.floor(param1 / 5)]);
            _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,param1);
         }
         AvatarManager.playerAvatarWorldView.updateNameBarLevelShape(param1);
      }
      
      public static function handleActorHealthStatus(param1:Object) : void
      {
         var _loc7_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:int = 2;
         var _loc5_:String = param1[_loc8_++];
         var _loc3_:int = int(param1[_loc8_++]);
         var _loc4_:QuestActor = _questActorsDict[_loc5_];
         if(_loc3_ == -1)
         {
            if(_loc4_ != null)
            {
               if(_loc4_._actorData.type == 23 || _loc4_._actorData.type == 11 && _loc4_._attackable > 0)
               {
                  _loc4_.setActorText("miss");
               }
            }
         }
         else
         {
            _loc7_ = _questActorDictionary[_loc5_];
            if(_loc7_ != null)
            {
               _loc7_.healthPercent = _loc3_;
            }
            if(_loc4_ != null)
            {
               _loc6_ = int(param1[_loc8_++]);
               _loc2_ = int(param1[_loc8_++]);
               _loc4_.healthUpdate(_loc3_,_loc6_,_loc2_ == 1);
            }
         }
      }
      
      public static function handleHealthUpdate(param1:Object, param2:Boolean) : void
      {
         var _loc6_:AvatarWorldView = null;
         var _loc4_:AvatarInfo = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:int = 2;
         var _loc11_:int = int(param1[_loc7_++]);
         var _loc12_:int = int(param1[_loc7_++]);
         var _loc3_:int = int(param1[_loc7_++]);
         var _loc5_:int = int(param1[_loc7_++]);
         var _loc13_:int = int(param1[_loc7_++]);
         var _loc8_:QuestPlayerData = getQuestPlayerData(_loc11_);
         if(_loc12_ == -1 && _loc3_ == 0)
         {
            if(_loc8_ != null)
            {
            }
         }
         else
         {
            _loc6_ = AvatarManager.avatarViewList[_loc11_];
            if(_loc8_ != null)
            {
               if(_loc3_ < 0)
               {
                  _loc8_.playerDamaged(_loc13_,_loc5_ + -_loc3_,_loc5_);
               }
               if(_loc6_)
               {
                  _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc6_.userName);
                  _loc4_.questHealthPercentage = _loc12_;
                  _loc4_.healthBase = _loc13_;
                  if(_loc4_.isDead && _loc12_ > 0)
                  {
                     _loc4_.isDead = false;
                     _loc6_.playAnim(16);
                  }
               }
               if(_loc3_ < 0)
               {
                  _loc8_.handleHit(_loc3_);
               }
               else
               {
                  _loc8_.handleHealing(_loc3_);
               }
            }
            if(_loc6_)
            {
               if(param2 && _loc6_ != AvatarManager.playerAvatarWorldView)
               {
                  _loc9_ = int(param1[_loc7_++]);
                  _loc10_ = int(param1[_loc7_++]);
                  _loc6_.setPos(_loc9_,_loc10_,false);
               }
               if(_loc12_ > 0)
               {
                  _loc6_.holdAnimId = 0;
               }
               _loc6_.updateNameBarHealth(_loc12_);
               if(_loc11_ == gMainFrame.server.userId)
               {
                  GuiManager.setQuestHearts(_loc12_);
               }
            }
         }
      }
      
      public static function handleQuestSetPath(param1:Object) : void
      {
         var _loc6_:int = 2;
         var _loc4_:String = param1[_loc6_++];
         var _loc2_:String = param1[_loc6_++];
         var _loc3_:QuestActor = _questActorsDict[_loc4_];
         var _loc5_:Object = _questActorDictionary[_loc4_];
         if(_loc5_ != null)
         {
            _loc5_.pathName = _loc2_;
         }
         if(_loc3_ != null)
         {
            _loc3_.setPath(_loc2_);
         }
      }
      
      public static function handleQuestVolumeInteractionUpdate(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc3_:Array = null;
         var _loc7_:int = 2;
         var _loc2_:String = param1[_loc7_++];
         var _loc4_:int = int(param1[_loc7_++]);
         _loc5_ = _questActorDictionary[_loc2_];
         if(_loc5_ != null)
         {
            if(_loc5_.progress == 0 && _loc4_ > 0)
            {
               playSound("ajq_chainstart");
            }
            if(_loc4_ > _loc5_.progress)
            {
               if(_progressingSC == null)
               {
                  _progressingSC = playLoopingSound("ajq_chain1lp");
                  if(_progressingSCnot)
                  {
                     _progressingSCnot.stop();
                     _progressingSCnot = null;
                  }
               }
               _volumeInteractionProgressing = true;
            }
            else if(_loc4_ < _loc5_.progress)
            {
               if(_volumeInteractionProgressing)
               {
                  playSound("ajq_chainstop");
               }
               if(_progressingSCnot == null)
               {
                  _progressingSCnot = playLoopingSound("ajq_chain2lp");
                  if(_progressingSC)
                  {
                     _progressingSC.stop();
                     _progressingSC = null;
                  }
               }
               _volumeInteractionProgressing = false;
            }
            if(_loc4_ == 100 && _progressingSC)
            {
               _progressingSC.stop();
               _progressingSC = null;
               playSound("ajq_phoenixstinger");
            }
            if(_loc4_ == 0 && _progressingSCnot)
            {
               _progressingSCnot.stop();
               _progressingSCnot = null;
            }
            _loc5_.progress = _loc4_;
            _loc3_ = _roomManager.findLayers(_loc2_);
            if(_loc3_ != null)
            {
               for each(var _loc6_ in _loc3_)
               {
                  if(_loc6_.s != null && _loc6_.s.content != null)
                  {
                     if(_loc6_.s.content.hasOwnProperty("setProgress"))
                     {
                        _loc6_.s.content.setProgress(_loc5_.progress);
                     }
                  }
               }
            }
         }
      }
      
      public static function handleQuestRoomChange(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc5_:int = int(param1[_loc4_++]);
         var _loc6_:String = param1[_loc4_++];
         var _loc3_:int = int(param1[_loc4_++]);
         var _loc2_:int = int(param1[_loc4_++]);
         AvatarManager.setOffScreenMapBySfsId(_loc5_,new Point(_loc3_,_loc2_),_loc6_);
         if(_questPlayersDict[_loc5_] != null)
         {
            _questPlayersDict[_loc5_].playerLeftRoom();
         }
      }
      
      public static function handlePlayerLeftQuest(param1:Object) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc9_:int = 2;
         var _loc10_:int = int(param1[_loc9_++]);
         var _loc2_:String = param1[_loc9_++];
         var _loc8_:AvatarWorldView = AvatarManager.avatarViewList[_loc10_];
         if(_loc8_)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc8_.userName);
            _loc5_.questTorchStatus = false;
         }
         AvatarManager.removeAvatar(_loc10_,true);
         var _loc3_:Object = QuestXtCommManager.getScriptDef(_questScriptDefId);
         var _loc4_:* = true;
         if(_loc3_)
         {
            _loc4_ = _loc3_.time != 1;
         }
         if(_loc4_ && AvatarManager.playerSfsUserId != _loc10_)
         {
            _loc7_ = 0;
            while(_loc7_ < _playerLeftObjects.length)
            {
               _loc6_ = _playerLeftObjects[_loc7_];
               if(!_loc6_.hasLeft)
               {
                  _loc6_.icon.txtMc.txt.autoSize = "center";
                  LocalizationManager.translateIdAndInsert(_loc6_.icon.txtMc.txt,11393,LocalizationManager.translateAvatarName(_loc2_));
                  _loc6_.icon.x = 900 * 0.5;
                  if(_loc7_ != 0 && !_playerLeftObjects[_loc7_ - 1].complete)
                  {
                     _playerLeftObjects[_loc7_ - 1].icon.y -= _loc6_.icon.height * _loc7_;
                  }
                  _loc6_.icon.y = 550 * 0.5;
                  GuiManager.guiLayer.addChild(_loc6_.icon);
                  _loc6_.icon.startLeaveText(onLeaveTextComplete,_loc7_);
                  _loc6_.hasLeft = true;
                  break;
               }
               _loc7_++;
            }
         }
         if(GuiManager.mainHud.playersCont != null)
         {
            if(GuiManager.mainHud.playersCont.visible)
            {
               onQuestPlayersBtn(null);
            }
         }
      }
      
      private static function onLeaveTextComplete(param1:Object) : void
      {
         _playerLeftObjects[param1].complete = true;
      }
      
      public static function handleGiveSeed(param1:int, param2:int, param3:int) : void
      {
         var _loc6_:Object = null;
         var _loc5_:Object = null;
         if(param1 == 0)
         {
            for(var _loc4_ in _questSeeds)
            {
               _loc6_ = _questSeeds[_loc4_];
               _loc6_.count = 0;
               _loc6_.max = 0;
            }
         }
         else
         {
            _loc5_ = _questSeeds[param1];
            if(_loc5_ == null)
            {
               _loc5_ = {};
            }
            if(_loc5_.count == param3 - 1 && param2 > _loc5_.count)
            {
               if(param1 == 564)
               {
                  playSound("ajq_SporePluck");
               }
               else
               {
                  playSound("ajq_boomSeedPluck");
               }
            }
            _loc5_.count = param2;
            _loc5_.max = param3;
            _questSeeds[param1] = _loc5_;
         }
         if(_seedInventory != null)
         {
            _seedInventory.rebuildInventory(_questSeeds);
         }
      }
      
      public static function handlePlantEatRecoil(param1:String) : void
      {
         var _loc2_:QuestActor = _questActorsDict[param1];
         if(_loc2_ != null)
         {
            _loc2_.recoil();
         }
      }
      
      public static function handlePlaySwf(param1:int) : void
      {
         if(param1 == 2607)
         {
            if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               param1 = 2718;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               param1 = 2736;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_DE)
            {
               param1 = 2761;
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               param1 = 2913;
            }
         }
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,onPlaySwfLoaded,true);
         startFadeOut();
      }
      
      public static function handleFade(param1:Boolean) : void
      {
         if(param1)
         {
            _queueFadeIn = true;
         }
         else
         {
            startFadeOut();
         }
      }
      
      public static function handlPreloadSwf(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1);
      }
      
      public static function handleAward(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = null;
         if(param1 == 78)
         {
            _loc3_ = new MediaHelper();
            _loc3_.init(56,onColorMeRad);
         }
         else
         {
            AchievementXtCommManager.requestSetUserVar(param1,param2);
         }
      }
      
      private static function onColorMeRad(param1:MovieClip) : void
      {
         GuiManager.guiLayer.addChild(param1);
         AJAudio.playAchievementSound();
         setTimeout(onRemoveColorMeRad,2000,param1);
      }
      
      private static function onRemoveColorMeRad(param1:MovieClip) : void
      {
         GuiManager.guiLayer.removeChild(param1);
      }
      
      public static function handlePostUri(param1:String) : void
      {
         SBTracker.trackPageview(param1);
      }
      
      public static function handleShake(param1:Number) : void
      {
         _shaketimer = param1 / 1000;
      }
      
      private static function onPlaySwfLoaded(param1:MovieClip) : void
      {
         _playSwfMC = param1;
      }
      
      private static function playSwf() : void
      {
         var _loc2_:Class = null;
         var _loc3_:String = null;
         var _loc1_:Number = NaN;
         UserCommXtCommManager.sendPermEmote(542);
         _playSwfMC.x = 0;
         _playSwfMC.y = 0;
         gMainFrame.stage.addChildAt(_playSwfMC,gMainFrame.stage.numChildren - 1);
         _playSwfMC.gotoAndStop(1);
         _playSwfMCTimeElapsed = 0;
         if(_playSwfMC.hasOwnProperty("soundToPlay"))
         {
            playSound(_playSwfMC.soundToPlay);
         }
         if(_playSwfMC.hasOwnProperty("playSoundOnLoad"))
         {
            _loc3_ = _playSwfMC.playSoundOnLoad;
            if(_loc3_ && _loc3_ != "")
            {
               _loc1_ = 0.49;
               if(_playSwfMC.hasOwnProperty("playSoundOnLoadVolume"))
               {
                  _loc1_ = Number(_playSwfMC.playSoundOnLoadVolume);
               }
               _loc2_ = _playSwfMC.loaderInfo.applicationDomain.getDefinition(_loc3_) as Class;
               _soundMan.addSound(_loc2_,_loc1_,_loc3_);
               _playSwfMCSC = _soundMan.play(_loc2_);
            }
         }
      }
      
      private static function startFadeOut() : void
      {
         _fader = new Shape();
         _fader.graphics.beginFill(0);
         _fader.graphics.drawRect(0,0,900,550);
         _fader.graphics.endFill();
         gMainFrame.stage.addChild(_fader);
         _faderState = 0;
         _fader.alpha = 0;
         if(_guiElementsSkipBtn && _guiElementsSkipBtn.parent)
         {
            gMainFrame.stage.addChild(_guiElementsSkipBtn);
         }
      }
      
      private static function startFadeIn() : void
      {
         _fader = new Shape();
         _fader.graphics.beginFill(0);
         _fader.graphics.drawRect(0,0,900,550);
         _fader.graphics.endFill();
         gMainFrame.stage.addChild(_fader);
         _faderState = 4;
         _fader.alpha = 1;
      }
      
      private static function endFade() : void
      {
      }
      
      public static function handleActorIcon(param1:String, param2:String) : void
      {
         var _loc3_:QuestActor = null;
         var _loc4_:Object = _questActorDictionary[param1];
         if(_loc4_ != null)
         {
            _loc4_.iconShowing = param2 == "1";
            _loc3_ = _questActorsDict[param1];
            if(_loc3_ != null)
            {
               _loc3_.updateIcon(_loc4_.iconShowing);
            }
         }
      }
      
      public static function handleQuestTorch(param1:Object) : void
      {
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc3_:Array = null;
         var _loc5_:QuestActor = null;
         var _loc12_:int = 0;
         var _loc8_:AvatarWorldView = null;
         var _loc4_:AvatarInfo = null;
         var _loc10_:int = 2;
         var _loc2_:* = param1[_loc10_++] == 0;
         var _loc11_:* = param1[_loc10_++] == 1;
         if(_loc2_)
         {
            _loc6_ = param1[_loc10_++];
            _loc7_ = _questActorDictionary[_loc6_];
            if(_loc7_ != null)
            {
               _loc7_.torchEnabled = _loc11_;
               if(_loc7_.type == 2)
               {
                  _loc3_ = _roomManager.findLayers(_loc6_);
                  if(_loc3_ != null)
                  {
                     for each(var _loc9_ in _loc3_)
                     {
                        _loc11_ ? addTorch(_loc9_) : removeTorch(_loc9_);
                     }
                  }
               }
               else
               {
                  _loc5_ = _questActorsDict[_loc6_];
                  if(_loc5_ != null)
                  {
                     _loc5_.updateTorch();
                  }
               }
            }
         }
         else
         {
            _loc12_ = int(param1[_loc10_++]);
            _loc8_ = AvatarManager.avatarViewList[_loc12_];
            if(_loc8_)
            {
               _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc8_.userName);
               _loc4_.questTorchStatus = _loc11_;
               if(_loc11_)
               {
                  addTorch(_loc8_,1.3,-15,-50);
               }
               else
               {
                  removeTorch(_loc8_);
               }
            }
         }
      }
      
      public static function handlePickGift(param1:Object, param2:Boolean) : void
      {
         var _loc7_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc13_:QuestActor = null;
         var _loc8_:Object = null;
         var _loc12_:Array = [];
         var _loc9_:int = 2;
         var _loc10_:int = int(param1[_loc9_++]);
         _adventureRewardsPopupType = param1[_loc9_++];
         if(!param2 && _adventureRewardsPopupType == 5)
         {
            _handlePickGiftDelayData = param1;
            _handlePickGiftDelayTimer = 1.5;
            return;
         }
         var _loc11_:Object = _questActorDictionary["gui_goal1a"];
         if((getAdventureType() == 1 || getAdventureType() == 4) && _loc11_ != null && _playerOrbCountTotal < _loc11_.state)
         {
            _loc7_ = {};
            _loc7_.type = 3;
            _loc7_.amount = 150;
            _loc12_.push(_loc7_);
            _loc5_ = 1;
            while(_loc5_ < _loc10_)
            {
               _loc7_ = {};
               _loc7_.type = 0;
               _loc12_.push(_loc7_);
               _loc5_++;
            }
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < _loc10_)
            {
               _loc7_ = {};
               _loc6_ = int(param1[_loc9_++]);
               _loc4_ = int(param1[_loc9_++]);
               _loc3_ = int(param1[_loc9_++]);
               _loc7_.type = _loc6_;
               switch(_loc7_.type)
               {
                  case 1:
                     _loc7_.defID = _loc4_;
                     break;
                  case 2:
                     _loc7_.defID = _loc4_;
                     _loc7_.color = _loc3_;
                     break;
                  case 3:
                     _loc7_.amount = _loc4_;
                     break;
                  case 4:
                     _loc7_.amount = _loc4_;
               }
               _loc12_.push(_loc7_);
               _loc5_++;
            }
         }
         _mediaLoader = new MediaHelper();
         var _loc14_:int = getAdventureType();
         if(_adventureGoals || _loc14_ == 5 || _loc14_ == 2 || _loc14_ == 7 || _loc14_ == 3 || _loc14_ == 6 || _loc14_ == 4 || _loc14_ == 8 || _loc14_ == 9)
         {
            if(_adventureRewardsPopup)
            {
               updateRewardsDisplay(_loc12_);
            }
            else
            {
               _mediaLoader.init(2754,onAdventureGoalRewardsLoaded,_loc12_);
            }
         }
         else if(_adventureRewardsPopup)
         {
            updateAdventureRewards(_loc12_);
         }
         else
         {
            _mediaLoader.init(2251,onAdventureRewardsLoaded,_loc12_);
         }
         if(_loc14_ == 1)
         {
            _loc5_ = 0;
            while(_loc5_ < _questActors.length)
            {
               _loc13_ = _questActors[_loc5_];
               if(_loc13_._actorData.type == 200)
               {
                  _loc8_ = _questActorDictionary[_loc13_._actorId];
                  if(_loc8_ != null)
                  {
                     _loc8_.healthPercent = 0;
                  }
                  _loc13_.destroy();
                  _questActors.splice(_loc5_,1);
                  _loc5_--;
                  delete _questActors[_loc13_._actorId];
               }
               _loc5_++;
            }
         }
      }
      
      public static function handleBeamZap(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc3_:String = param1[_loc4_++];
         var _loc5_:int = int(param1[_loc4_++]);
         var _loc2_:QuestActor = _questActorsDict[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleBeamZap(_loc5_);
         }
      }
      
      public static function handlePhantomZap(param1:Object) : void
      {
         var _loc4_:int = 2;
         var _loc3_:String = param1[_loc4_++];
         var _loc5_:int = int(param1[_loc4_++]);
         var _loc2_:QuestActor = _questActorsDict[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handlePhantomZap(_loc5_);
         }
      }
      
      public static function handlePlantAte(param1:String, param2:String) : void
      {
         var _loc3_:QuestActor = _questActorsDict[param1];
         var _loc4_:Object = _questActorDictionary[param1];
         if(_loc4_ != null)
         {
            _loc4_.plantEaten = true;
         }
         if(_loc3_ != null)
         {
            _loc3_.setPlantEats(_questActorsDict[param2]);
         }
      }
      
      public static function handlePlantSeed(param1:Object) : void
      {
         var _loc6_:String = null;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         var _loc10_:AvatarWorldView = null;
         var _loc11_:int = 2;
         var _loc5_:* = param1[_loc11_++] == "1";
         var _loc8_:String = param1[_loc11_++];
         if(_loc5_)
         {
            _loc6_ = param1[_loc11_++];
            _loc3_ = int(param1[_loc11_++]);
            _loc9_ = int(param1[_loc11_++]);
            _loc7_ = int(param1[_loc11_++]);
            _loc2_ = int(param1[_loc11_++]);
            _loc4_ = {};
            _loc4_.visible = true;
            _loc4_.requireClick = false;
            _loc4_.type = 21;
            _loc4_.defId = _loc3_;
            _loc4_.state = 0;
            _loc4_.actorName = _loc6_;
            initInitialActorStatus(_loc4_,null);
            _loc4_.actorPos = new Point(_loc9_,_loc7_);
            _loc10_ = AvatarManager.avatarViewList[_loc2_];
            if(_loc10_)
            {
               _loc4_.seedLaunchX = _loc10_.avatarPos.x;
               _loc4_.seedLaunchY = _loc10_.avatarPos.y;
            }
            _questActorDictionary[_loc6_] = _loc4_;
            initQuestActor(_loc4_.actorName,0,100,_loc4_,null,null);
         }
         if(_seedInventory && _loc8_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _seedInventory.removeLastDraggedSeed();
         }
      }
      
      public static function handleQuestPlayerDead(param1:Object) : void
      {
         var _loc4_:AvatarInfo = null;
         var _loc5_:String = null;
         var _loc3_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 2;
         var _loc2_:int = int(param1[_loc8_++]);
         var _loc6_:AvatarWorldView = AvatarManager.avatarViewList[_loc2_];
         if(_loc6_)
         {
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc6_.userName);
            if(_loc4_ != null)
            {
               _loc4_.isDead = true;
            }
            if(Utility.isLand(_loc6_.avatarData.enviroTypeFlag) || Utility.isAir(_loc6_.avatarData.enviroTypeFlag))
            {
               _loc6_.playAnim(22);
               _loc6_.holdAnimId = 22;
            }
            else
            {
               _loc6_.playAnim(40);
               _loc6_.holdAnimId = 40;
            }
            if(_loc6_ == AvatarManager.playerAvatarWorldView)
            {
               _loc5_ = uint(_loc6_.avatarPos.x).toString(16);
               _loc3_ = uint(_loc6_.avatarPos.y).toString(16);
               while(_loc5_.length < 8)
               {
                  _loc5_ = "0" + _loc5_;
               }
               while(_loc3_.length < 8)
               {
                  _loc3_ = "0" + _loc3_;
               }
               _loc7_ = gMainFrame.server.getCurrentRoomName().split(".")[1];
               SBTracker.trackPageview("adventure/" + _questScriptDefId + "/#death/" + _loc7_ + "#null#x" + _loc5_ + _loc3_);
               _roomManager.forceStopMovement();
               _defeatedPopUpTimer = 2;
               playSound("ajq_playerdeath");
               if(_seedInventory)
               {
                  _seedInventory.removeLastDraggedSeed();
               }
            }
         }
      }
      
      public static function handleSwipe(param1:Object) : void
      {
         var _loc10_:int = 2;
         var _loc3_:int = int(param1[_loc10_++]);
         var _loc9_:int = int(param1[_loc10_++]);
         var _loc6_:int = int(param1[_loc10_++]);
         var _loc4_:String = param1[_loc10_++];
         var _loc5_:int = int(param1[_loc10_++]);
         var _loc2_:uint = uint(param1[_loc10_++]);
         var _loc7_:QuestActor = null;
         var _loc8_:AvatarWorldView = null;
         if(_loc5_ > 0)
         {
            _loc8_ = AvatarManager.avatarViewList[_loc5_];
            if(_loc8_ == null)
            {
               return;
            }
            _loc8_.faceAnim(_loc9_ - _loc8_.avatarPos.x,_loc6_ - _loc8_.avatarPos.y,false);
         }
         else
         {
            _loc7_ = _questActorsDict[_loc4_];
         }
         swipeMelee(_loc3_,_loc2_,_loc9_,_loc6_,_loc7_,_loc8_);
      }
      
      public static function handleRDNE() : void
      {
         if(_questExitPending == false && _questActorDictionary != null)
         {
            commandExit();
            onExitRoom();
         }
      }
      
      public static function handleActorDeath(param1:Object) : void
      {
         var _loc12_:QuestActor = null;
         var _loc10_:String = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc11_:QuestActor = null;
         var _loc4_:int = 0;
         var _loc7_:int = 2;
         _loc10_ = param1[_loc7_++];
         var _loc5_:Object = _questActorDictionary[_loc10_];
         _loc12_ = _questActorsDict[_loc10_];
         _loc2_ = int(param1[_loc7_++]);
         var _loc13_:* = param1[_loc7_++] == "1";
         var _loc8_:int = int(param1[_loc7_++]);
         var _loc9_:int = int(param1[_loc7_++]);
         var _loc6_:String = param1[_loc7_++];
         if(_loc6_ != "")
         {
            _loc3_ = _questActorDictionary[_loc6_];
            if(_loc3_ != null)
            {
               _loc3_.actorPos = new Point(_loc8_,_loc9_);
            }
            _loc11_ = _questActorsDict[_loc6_];
            if(_loc11_ != null)
            {
               _loc11_.x = _loc8_;
               _loc11_.y = _loc9_;
               _loc11_.handlePositionUpdate(_loc8_,_loc9_,0,0,0,0);
            }
         }
         if(_loc5_ != null)
         {
            _loc5_.healthPercent = 0;
         }
         if(_loc12_ != null)
         {
            if(_loc13_)
            {
               _loc12_.x = _loc8_;
               _loc12_.y = _loc9_;
               _loc12_.handlePositionUpdate(_loc8_,_loc9_,0,0,0,0);
            }
            if(_loc12_.handleDeath(_loc2_))
            {
               _loc4_ = 0;
               while(_loc4_ < _questActors.length)
               {
                  if(_questActors[_loc4_]._actorId == _loc10_)
                  {
                     _questActors.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
               _loc12_.destroy();
               delete _questActorsDict[_loc10_];
            }
         }
      }
      
      public static function onQuestExit(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(10683),true,onLeaveQuestConfirm);
      }
      
      private static function onDropItemConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            QuestXtCommManager.sendQuestDropItem(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y,param1.passback);
         }
      }
      
      private static function onLeaveQuestConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            commandExit();
         }
      }
      
      private static function onDeathAccept(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1.status)
         {
            _loc2_ = 0;
            _loc3_ = 0;
            QuestXtCommManager.sendQuestPlayerRequestRespawn(0,_nearestRespawnPoint != null ? _nearestRespawnPoint.pos.x : AvatarManager.playerAvatarWorldView.x,_nearestRespawnPoint != null ? _nearestRespawnPoint.pos.y : AvatarManager.playerAvatarWorldView.y);
         }
         else
         {
            commandExit();
         }
      }
      
      public static function respawnPlayer() : void
      {
         var _loc1_:Point = null;
         if(_nearestRespawnPoint != null)
         {
            _loc1_ = new Point(_roomManager.scrollOffset.x,_roomManager.scrollOffset.y);
            _roomManager.teleportPlayer(_nearestRespawnPoint.pos.x,_nearestRespawnPoint.pos.y,true);
            _roomManager.setCameraFocus(_loc1_,0,0,1,false);
            playSound("ajq_respawn");
         }
      }
      
      public static function handleQuestPlayerRequestRespawn(param1:Object) : void
      {
         respawnPlayer();
      }
      
      public static function closeAdventurePopups() : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
            QuestXtCommManager.sendQuestJoinCancel();
         }
         if(_talkingPopup != null)
         {
            onTalkingPopupClose(null);
         }
         if(_rewardsGiftPopup != null)
         {
            _rewardsGiftPopup.destroy();
            _rewardsGiftPopup = null;
         }
      }
      
      private static function onPopupOK(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
      }
      
      public static function set npcDefs(param1:Object) : void
      {
         _npcDefs = param1;
      }
      
      public static function getNPCDef(param1:int) : Object
      {
         if(_npcDefs)
         {
            return _npcDefs[param1];
         }
         return null;
      }
      
      public static function questRoomJoined(param1:Boolean) : void
      {
         _inQuestRoom = param1;
         if(param1)
         {
            _isQuestLikeNormalRoom = false;
            QuestXtCommManager.sendQuestMovedItemsRequest();
            loadQuestSfx(1970,onGlobalSfxLoaded);
         }
      }
      
      public static function inQuestRoom() : Boolean
      {
         return _inQuestRoom;
      }
      
      public static function isQuestLikeNormalRoom() : Boolean
      {
         return _isQuestLikeNormalRoom;
      }
      
      private static function onTimerLoaded(param1:MovieClip) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         if(_questActorDictionary != null)
         {
            _loc2_ = _questActorDictionary["gui_timer"];
            _loc3_ = _loc2_ != null ? _loc2_.state / 60 : 0;
            GuiManager.guiLayer.addChild(param1);
            param1.x = 400;
            param1.y = 50;
            _adventureTimer = param1;
            _adventureTimer.clock.clockText_1.text = _loc3_;
            _adventureTimer.clock.clockText_2.text = "00";
            _adventureTimer.time = _loc3_;
            if(_loc3_ == 0)
            {
               _adventureTimer.visible = false;
            }
         }
      }
      
      private static function onHotColdLoaded(param1:MovieClip) : void
      {
         if(_questActorDictionary != null)
         {
            GuiManager.guiLayer.addChild(param1);
            param1.x = 0;
            param1.y = 0;
            _adventureHotColdStatus = 0;
            _adventureHotCold = param1;
            _adventureHotCold.setState(_adventureHotColdStatus);
         }
      }
      
      private static function onGuiGoalLoaded(param1:MovieClip) : void
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         if(_questActorDictionary != null)
         {
            _loc5_ = int(param1.passback.goalId);
            _loc6_ = "gui_goal" + _loc5_;
            _loc2_ = _questActorDictionary[_loc6_];
            _loc3_ = "gui_goal" + _loc5_ + "a";
            _loc4_ = _questActorDictionary[_loc3_];
            if(_loc2_ && _loc4_)
            {
               param1.setState(_loc5_);
               switch(getAdventureType() - 1)
               {
                  case 0:
                     param1.setQuestType(2);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 2:
                     param1.setQuestType(3);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 3:
                     param1.setQuestType(4);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 4:
                     param1.setQuestType(5);
                     param1.setValue(_loc4_.state + 1 - _playerCrystalCount);
                     param1.setMaxValue(_loc4_.state + 1);
                     break;
                  case 5:
                     param1.setQuestType(6);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 6:
                     param1.setQuestType(2);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 7:
                     param1.setQuestType(8);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  case 8:
                     param1.setQuestType(8);
                     param1.setValue(_playerCrystalCount);
                     param1.setMaxValue(0);
                     break;
                  default:
                     param1.setValue(_loc2_.state);
                     param1.setMaxValue(_loc4_.state);
               }
               GuiManager.guiLayer.addChild(param1);
               param1.x = 20;
               param1.y = 25 + 50 * (_loc5_ - 1);
               if(_adventureGoals == null)
               {
                  _adventureGoals = [];
               }
               _adventureGoals[_loc5_] = param1;
            }
            else if(_questActorDictionary["showorbcount"] != null)
            {
               param1.setState(_loc5_);
               param1.setQuestType(7);
               param1.setValue(_playerCrystalCount);
               GuiManager.guiLayer.addChild(param1);
               param1.x = 20;
               param1.y = 25 + 50 * (_loc5_ - 1);
               if(_adventureGoals == null)
               {
                  _adventureGoals = [];
               }
               _adventureGoals[_loc5_] = param1;
            }
         }
      }
      
      public static function playerLaunchWeapon(param1:Point, param2:Boolean) : Number
      {
         var _loc5_:Object = null;
         var _loc3_:Number = 0;
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(AvatarManager.playerAvatarWorldView.userName);
         if(_playerWeaponTimerProjectile <= 0 && _loc4_ != null && _loc4_.questHealthPercentage > 0)
         {
            _loc5_ = getPlayerActiveWeapon(param2);
            _playerWeaponTimerProjectile = 0.5;
            if(param2)
            {
               _loc3_ = launchProjectile(_loc5_.defId,_loc5_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, ranged"]);
               }
            }
            else
            {
               _loc3_ = swipeMelee(_loc5_.defId,_loc5_.color,param1.x,param1.y,null,AvatarManager.playerAvatarWorldView);
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["dm","attack with weapon, melee"]);
               }
            }
         }
         return _loc3_;
      }
      
      public static function launchProjectile(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc9_:QuestProjectile = null;
         var _loc8_:Boolean = false;
         var _loc7_:Number = 0;
         if(param1 != 0)
         {
            _loc9_ = null;
            if(_loc9_ == null)
            {
               _loc9_ = new QuestProjectile();
               _loc8_ = _loc9_.launch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            else
            {
               _loc8_ = _loc9_.relaunch(param1,param2,_layerManager.room_chat,param3,param4,param5,param6);
            }
            if(_loc8_)
            {
               _loc7_ = _loc9_.angle;
               _questProjectiles.push(_loc9_);
            }
         }
         return _loc7_;
      }
      
      public static function swipeMelee(param1:int, param2:uint, param3:Number, param4:Number, param5:QuestActor, param6:AvatarView) : Number
      {
         var _loc8_:QuestMelee = null;
         var _loc7_:Number = 0;
         if(param1 != 0)
         {
            _loc8_ = new QuestMelee(_currentMeleeID++);
            if(_loc8_.swipe(param1,param2,_layerManager.room_chat,param3,param4,param5,param6))
            {
               _loc7_ = _loc8_.angle;
               _questMelees.push(_loc8_);
            }
         }
         return _loc7_;
      }
      
      public static function getPlayerActiveWeapon(param1:Boolean) : Object
      {
         var _loc2_:AccItemCollection = null;
         var _loc7_:int = 0;
         var _loc6_:Item = null;
         var _loc4_:Object = null;
         var _loc5_:* = null;
         if(!isBeYourPetQuest())
         {
            _loc2_ = AvatarManager.playerAvatar.inventoryClothing.itemCollection;
            _loc7_ = 0;
            while(_loc7_ < _loc2_.length)
            {
               _loc6_ = _loc2_.getAccItem(_loc7_);
               if(_loc6_.getInUse(AvatarManager.playerAvatar.avInvId) && _loc6_.attackMediaRefId != 0)
               {
                  if(param1 && _loc6_.combatType == 1 || param1 == false && _loc6_.combatType == 0)
                  {
                     if(_loc5_ == null || _loc5_.attack < _loc6_.attack)
                     {
                        _loc5_ = _loc6_;
                     }
                  }
               }
               _loc7_++;
            }
         }
         var _loc3_:Object = {};
         if(_loc5_ == null)
         {
            _loc3_.defId = param1 ? 0 : 123;
            _loc4_ = ItemXtCommManager.getItemDef(_loc3_.defId);
            if(_loc4_ != null)
            {
               _loc3_.color = _loc4_.colors[0];
            }
            else
            {
               _loc3_.color = 0;
            }
         }
         else
         {
            _loc3_.defId = _loc5_.defId;
            _loc3_.color = _loc5_.color;
         }
         return _loc3_;
      }
      
      public static function handleQuestMiniGameComplete(param1:int) : void
      {
         if(_questCommandActorMiniGame != "" && _questCommandActorStateMiniGame != -1)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","quest minigame complete, actor:" + _questCommandActorMiniGame + " actorState:" + _questCommandActorStateMiniGame + " gameResult:" + param1]);
            }
            QuestXtCommManager.questMiniGameComplete(_questCommandActorMiniGame,_questCommandActorStateMiniGame,param1);
            _questCommandActorMiniGame = null;
            _questCommandActorStateMiniGame = -1;
         }
      }
      
      public static function stopItemEmoticonSound(param1:AvatarWorldView) : void
      {
         var _loc2_:Object = null;
         var _loc3_:QuestPlayerData = null;
         for(_loc2_ in _questPlayersDict)
         {
            _loc3_ = _questPlayersDict[_loc2_];
            if(_loc3_ != null && _loc3_._avatarWorldView == param1)
            {
               _loc3_.stopItemEmoticonSound();
               break;
            }
         }
      }
      
      public static function playItemEmoticonSound(param1:AvatarWorldView, param2:String) : void
      {
         for each(var _loc4_ in _questPlayersDict)
         {
            if(_loc4_ != null && _loc4_._avatarWorldView == param1)
            {
               _loc4_.playItemEmoticonSound(param2);
               break;
            }
         }
      }
      
      public static function onQuestPlayersBtn(param1:MouseEvent) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:Object = null;
         var _loc5_:Array = null;
         if(param1 == null || !param1.currentTarget.isGray)
         {
            _loc4_ = GuiManager.mainHud.playersCont;
            if(param1 != null && _loc4_.visible)
            {
               _loc4_.visible = false;
               return;
            }
            _loc4_.visible = true;
            if(GuiManager.mainHud.miniMap.visible)
            {
               GuiManager.mainHud.miniMap.visible = false;
               GuiManager.mainHud.miniMap_btnQuest.downToUpState();
            }
            if(_playersWindow)
            {
               _playersWindow.destroy();
               _playersWindow = null;
            }
            _loc3_ = AvatarManager.adventurePlayerData;
            _loc5_ = [];
            for each(var _loc2_ in _loc3_)
            {
               if(_loc2_.userName != gMainFrame.userInfo.myUserName)
               {
                  _loc5_.push({
                     "isMember":_loc2_.isMember,
                     "nameBarData":_loc2_.nameBarData,
                     "moderatedUserName":_loc2_.userName,
                     "userName":_loc2_.userName,
                     "avName":_loc2_.avName,
                     "isBuddy":BuddyManager.isBuddy(_loc2_.userName),
                     "isBlocked":BuddyManager.isBlocked(_loc2_.userName)
                  });
               }
            }
            if(_loc5_.length > 0)
            {
               while(_loc4_.itemWindow.numChildren > 0)
               {
                  _loc4_.itemWindow.removeChildAt(0);
               }
               _playersWindow = new WindowGenerator();
               _playersWindow.init(1,_loc5_.length,_loc5_.length,4,4,4,ItemWindowNameBar,_loc5_,"",{
                  "mouseDown":onSelectPlayer,
                  "mouseOver":null,
                  "mouseOut":null
               },null,onReportWindowsLoaded);
            }
            else
            {
               _loc4_.visible = false;
               GuiManager.mainHud.questPlayersBtn.downToUpState();
               GuiManager.mainHud.questPlayersBtn.activateGrayState(true);
            }
         }
      }
      
      private static function onReportWindowsLoaded() : void
      {
         var containerWindow:MovieClip;
         var maxHeight:int;
         var needsScrollbar:Boolean;
         var i:int = 0;
         while(i < _playersWindow.bg.numChildren)
         {
            ItemWindowNameBar(_playersWindow.bg.getChildAt(i)).updateToBeCentered(_playersWindow.width);
            i++;
         }
         containerWindow = GuiManager.mainHud.playersCont;
         containerWindow.itemWindow.addChild(_playersWindow);
         maxHeight = _playersWindow.boxHeight * 10;
         needsScrollbar = _playersWindow.height >= maxHeight;
         with(containerWindow)
         {
            m.height = Math.min(maxHeight,Math.round(_playersWindow.height));
            if(needsScrollbar)
            {
               m.width = t.width = b.width = _playersWindow.width + 2 + 31;
            }
            else
            {
               m.width = t.width = b.width = _playersWindow.width + 2;
            }
            m.y = b.y - m.height;
            t.y = m.y - t.height;
            x = Math.min(GuiManager.mainHud.questPlayersBtn.x - width * 0.5,MainFrame.VIEW_WIDTH - width - 10);
            if(needsScrollbar)
            {
               itemWindow.y = t.y + t.height + 20;
            }
            else
            {
               itemWindow.y = t.y + t.height + 10;
            }
            itemWindow.x = m.x + (m.width - _playersWindow.width) * 0.35;
            title.y = t.y + 5;
            title.x = m.width * 0.5 - title.width * 0.5;
         }
         if(_playersWindow.height >= maxHeight)
         {
            containerWindow.itemWindow.x -= 15;
            _playersWindowScrollBar = new SBScrollbar();
            _playersWindowScrollBar.init(_playersWindow,_playersWindow.width,maxHeight,-2,"scrollbar2",_playersWindow.boxHeight);
         }
      }
      
      public static function validatePlantSeedLocation(param1:Point) : Boolean
      {
         var _loc4_:QuestActor = null;
         var _loc3_:int = 0;
         var _loc2_:QuestActor = null;
         _loc3_ = 0;
         while(_loc3_ < _questActors.length)
         {
            _loc4_ = _questActors[_loc3_];
            if(_loc4_._actorData.type == 22)
            {
               if(_loc4_.testPointInActorVolumes(param1))
               {
                  _loc2_ = getNearestPlant(param1.x,param1.y,75,999999);
                  if(_loc2_ != null)
                  {
                     return false;
                  }
                  return true;
               }
            }
            _loc3_++;
         }
         return false;
      }
      
      private static function onSelectPlayer(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         BuddyManager.showBuddyCard({
            "userName":param1.currentTarget.userName,
            "onlineStatus":1
         });
      }
      
      private static function resetMouseMoveIdleTimer(param1:MouseEvent) : void
      {
         if(_kickPopup == null)
         {
            _gameIdleTimer = 0;
         }
      }
      
      private static function resetMouseDownIdleTimer(param1:Event) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private static function onKickWarningPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         _kickPopup = null;
         _gameIdleTimer = 0;
      }
      
      private static function adventureJoinClose() : void
      {
         if(_adventureJoin)
         {
            _adventureJoin.destroy();
            _adventureJoin = null;
         }
      }
      
      public static function openAdventureSelectPopup() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _mediaLoader = new MediaHelper();
         _mediaLoader.init(2603,onAdventureSelectLoaded);
      }
      
      private static function onAdventureSelectLoaded(param1:MovieClip = null) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _adventureSelectPopup = MovieClip(param1.getChildAt(0));
         }
         if(_adventureSelectPopup)
         {
            if(_availableScriptDefs)
            {
               _adventureSelectPopup.bx.addEventListener("mouseDown",onAdventureSelectClose,false,0,true);
               if(_adventureSelectScrollBar)
               {
                  _adventureSelectScrollBar.destroy();
                  _adventureSelectScrollBar = null;
               }
               if(_adventureSelectItemWindow)
               {
                  _adventureSelectItemWindow.destroy();
                  _adventureSelectItemWindow = null;
               }
               _loc2_ = Math.min(_availableScriptDefs.length,20);
               _adventureSelectItemWindow = new WindowGenerator();
               _adventureSelectItemWindow.init(1,_loc2_,_loc2_,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":adventureMouseDown},{"scriptIds":_availableScriptDefs},onAdventureWindowsLoaded,false,false);
            }
            else
            {
               getAvailableScriptDefs(onAdventureSelectLoaded);
            }
         }
      }
      
      private static function onAdventureWindowsLoaded() : void
      {
         while(_adventureSelectPopup.itemWindow.numChildren > 2)
         {
            _adventureSelectPopup.itemWindow.removeChildAt(_adventureSelectPopup.itemWindow.numChildren - 1);
         }
         _adventureSelectPopup.itemWindow.addChild(_adventureSelectItemWindow);
         _adventureSelectScrollBar = new SBScrollbar();
         _adventureSelectScrollBar.init(_adventureSelectItemWindow,267,337,3,"scrollbar2",54);
         _adventureSelectPopup.x = 900 * 0.5;
         _adventureSelectPopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_adventureSelectPopup);
         DarkenManager.darken(_adventureSelectPopup);
      }
      
      private static function adventureMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = param1.currentTarget.performContinueChecks();
         if(_loc2_ != null)
         {
            onAdventureSelectClose(param1);
            _loc2_.func(_loc2_.defId);
            _loc2_ = null;
         }
      }
      
      private static function onAdventureSelectClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _adventureSelectScrollBar.destroy();
         _adventureSelectScrollBar = null;
         _adventureSelectItemWindow.destroy();
         _adventureSelectItemWindow = null;
         DarkenManager.unDarken(_adventureSelectPopup);
         GuiManager.guiLayer.removeChild(_adventureSelectPopup);
         _adventureSelectPopup = null;
      }
      
      public static function privateAdventureJoinClose(param1:Boolean, param2:Boolean = true) : void
      {
         if(_privateAdventureJoin)
         {
            if(param1)
            {
               QuestXtCommManager.sendQuestJoinCancel();
            }
            if(param2)
            {
               UserCommXtCommManager.sendCustomAdventureMessage(false);
            }
            else
            {
               GuiManager.setSwapBtnGray(false);
            }
            _privateAdventureJoin.destroy();
            _privateAdventureJoin = null;
         }
         else
         {
            GuiManager.setSwapBtnGray(false);
         }
      }
      
      public static function getNearestActorPathInGroupToPlayerInRange(param1:QuestActor) : Boolean
      {
         var _loc5_:String = null;
         var _loc3_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc2_:QuestActor = null;
         var _loc4_:int = int(param1._actorId.lastIndexOf("__"));
         if(_loc4_ != -1)
         {
            _loc5_ = param1._actorId.substring(0,_loc4_);
            _loc3_ = _questActorGroups[_loc5_];
            if(_loc3_ != null)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc3_.length)
               {
                  _loc7_ = _loc3_[_loc6_];
                  _loc2_ = _questActorsDict[_loc7_];
                  if(_loc2_ != null)
                  {
                     if(_loc2_.pathToPlayerInRange())
                     {
                        return true;
                     }
                  }
                  _loc6_++;
               }
            }
            return false;
         }
         return param1.pathToPlayerInRange();
      }
      
      public static function showLeaveQuestLobbyPopup(... rest) : void
      {
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14815),true,onConfirmLeave,rest);
      }
      
      private static function onConfirmLeave(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(param1.status)
         {
            privateAdventureJoinClose(true);
            _loc2_ = param1.passback[0];
            param1.passback.splice(0,1);
            _loc2_.apply(null,param1.passback);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private static function startShake() : void
      {
         var _loc1_:Object = null;
         if(_layerManager != null)
         {
            _loc1_ = _layerManager.bkg;
            _shakeOrigPos = new Point(_loc1_.x,_loc1_.y);
            _soundMan.play(_sounds["ajq_volcanoerupt"]);
         }
      }
      
      private static function stopShake() : void
      {
         var _loc1_:Object = null;
         if(_layerManager != null)
         {
            _loc1_ = _layerManager.bkg;
            _loc1_.x = _shakeOrigPos.x;
            _loc1_.y = _shakeOrigPos.y;
         }
         if(_screenShakeSC)
         {
            _soundMan.stop(_screenShakeSC);
            _screenShakeSC = null;
         }
         _shakeOrigPos = null;
      }
      
      private static function shake() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(_layerManager != null)
         {
            _loc2_ = _layerManager.bkg;
            _loc1_ = 16;
            _loc2_.x = _loc2_.x + Math.random() * _loc1_ - _loc1_ / 2;
            _loc2_.y = _loc2_.y + Math.random() * _loc1_ - _loc1_ / 2;
         }
      }
      
      public static function isPlayerInStealthVolume() : Boolean
      {
         return _playerInStealthVolume || _talkingPopup != null;
      }
      
      public static function currencyUpdate(param1:int) : void
      {
         if(_questActorDictionary != null)
         {
            _totalGemsEarned += param1;
         }
      }
      
      public static function onShopClick(param1:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc3_:Object = null;
         var _loc2_:Boolean = true;
         if(_questActorDictionary != null)
         {
            _loc4_ = "_" + param1;
            _loc3_ = _questActorDictionary[_loc4_];
            if(_loc3_)
            {
               if(_loc3_.state != 1)
               {
                  _loc2_ = false;
               }
            }
            else
            {
               Utility.showErrorOnScreen("On Shop Click: actorData is null. volName is " + param1 + " actorName is " + _loc4_);
               GATracker.trackError("On Shop Click: actorData is null. volName is " + param1 + " actorName is " + _loc4_,false);
            }
         }
         return _loc2_;
      }
      
      public static function onShopClose() : void
      {
         updateCombinedCurrency();
         if(_questActorDictionary != null && _questActorDictionary["gui_34"] != null)
         {
            QuestXtCommManager.questActorTriggered("gui_34");
         }
      }
      
      public static function avatarEditorInitComplete() : void
      {
         var _loc1_:int = 0;
         var _loc2_:AvatarEditor = null;
         var _loc4_:Object = null;
         var _loc3_:Object = null;
         if(_questActorDictionary != null && _questActorDictionary["gui_aved"] != null)
         {
            _loc2_ = GuiManager.avatarEditor;
            if(_loc2_ != null)
            {
               _loc1_ = 0;
               while(_loc1_ < _guiElementsAvatarEditor.length)
               {
                  _loc4_ = _loc2_.avEditor[_guiElementsAvatarEditor[_loc1_ + 1]];
                  if(_loc4_ == null)
                  {
                     _loc4_ = _loc2_[_guiElementsAvatarEditor[_loc1_ + 1]];
                  }
                  if(_loc4_)
                  {
                     _loc3_ = _questActorDictionary[_guiElementsAvatarEditor[_loc1_]];
                     if(_loc3_.state >= 0 && _loc3_.state <= 2)
                     {
                        if(_loc4_.hasOwnProperty("setButtonState"))
                        {
                           _loc4_.setButtonState(_loc3_.state);
                        }
                        _loc4_.addEventListener("mouseDown",avEdDownHandler,false,0,true);
                        if(_loc4_.name != _guiElementsAvatarEditor[_loc1_ + 1])
                        {
                           _loc4_.name = _guiElementsAvatarEditor[_loc1_ + 1];
                        }
                     }
                  }
                  _loc1_ += 2;
               }
            }
            QuestXtCommManager.questActorTriggered("gui_aved");
         }
      }
      
      public static function phantomAttackDestructible(param1:String, param2:int, param3:int, param4:int) : void
      {
         var _loc10_:QuestActor = null;
         var _loc8_:int = 0;
         var _loc12_:Point = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:int = 0;
         var _loc5_:int = getTimer();
         _loc8_ = 0;
         while(_loc8_ < _questActors.length)
         {
            _loc10_ = _questActors[_loc8_];
            if(_loc10_._visible && !_loc10_.getIsDead() && _loc10_._actorData.type == 23)
            {
               if(_loc10_._actorData.damageDelay + 2000 < _loc5_)
               {
                  _loc12_ = _loc10_.actorOffset;
                  _loc6_ = param2 - (_loc10_.x + _loc12_.x);
                  _loc7_ = param3 - (_loc10_.y + _loc12_.y);
                  _loc9_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
                  _loc11_ = (param4 + param4) * (param4 + param4);
                  if(_loc9_ < _loc11_)
                  {
                     QuestXtCommManager.questPhantomAttackDestructible(param1,_loc10_._actorId);
                     _loc10_._actorData.damageDelay = _loc5_;
                  }
               }
            }
            _loc8_++;
         }
      }
      
      public static function playerJoinedQuestRoom(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:QuestPlayerData = null;
         if(_questActorDictionary != null)
         {
            if(isDynamicallyJoinableQuest())
            {
               if(GuiManager.mainHud.questPlayersBtn != null)
               {
                  GuiManager.mainHud.questPlayersBtn.activateGrayState(false);
                  if(GuiManager.mainHud.playersCont.visible)
                  {
                     onQuestPlayersBtn(null);
                  }
               }
            }
            if(_questPlayersSwitched != null)
            {
               if(_questPlayersSwitched[param1] != null)
               {
                  _loc2_ = int(_questPlayersSwitched[param1]);
                  _loc3_ = getQuestPlayerData(param1);
                  if(_loc3_ != null)
                  {
                     _loc3_.setAvatarSwitched(_loc2_);
                  }
               }
            }
         }
      }
      
      public static function questPhantomZap(param1:String, param2:int, param3:int, param4:int, param5:QuestActor) : void
      {
         if(param5 != null && param5.isRunawayFromPlayer())
         {
            questActorAttacked(param5._actorId,-1,0,0,param5);
         }
         else
         {
            QuestXtCommManager.questPhantomZap(param1,param2,param3,param4);
         }
      }
      
      public static function questActorAttacked(param1:String, param2:int, param3:int, param4:int, param5:QuestActor) : void
      {
         if(param1 == "" && param5 != null && param5.isRunawayFromPlayer())
         {
            QuestXtCommManager.questActorAttacked(param5._actorId,-1,0,0);
         }
         else
         {
            QuestXtCommManager.questActorAttacked(param1,param2,param3,param4);
         }
      }
      
      public static function getAdventureType() : int
      {
         var _loc1_:Object = _questActorDictionary["advtype1"];
         if(_loc1_ != null)
         {
            return 1;
         }
         _loc1_ = _questActorDictionary["advtype2"];
         if(_loc1_ != null)
         {
            return 2;
         }
         _loc1_ = _questActorDictionary["advtype3"];
         if(_loc1_ != null)
         {
            return 3;
         }
         _loc1_ = _questActorDictionary["advtype4"];
         if(_loc1_ != null)
         {
            return 4;
         }
         _loc1_ = _questActorDictionary["advtype5"];
         if(_loc1_ != null)
         {
            return 5;
         }
         _loc1_ = _questActorDictionary["advtype6"];
         if(_loc1_ != null)
         {
            return 6;
         }
         _loc1_ = _questActorDictionary["advtype7"];
         if(_loc1_ != null)
         {
            return 7;
         }
         _loc1_ = _questActorDictionary["advtype8"];
         if(_loc1_ != null)
         {
            return 8;
         }
         _loc1_ = _questActorDictionary["advtype9"];
         if(_loc1_ != null)
         {
            return 9;
         }
         return 0;
      }
      
      public static function allowItemDrop() : Boolean
      {
         switch(getAdventureType() - 5)
         {
            case 0:
            case 3:
               return false;
            default:
               return _questActorDictionary["advnodrop"] == null;
         }
      }
      
      public static function livePlayerCount() : int
      {
         var _loc1_:Object = _questActorDictionary["live_players"];
         return _loc1_ == null ? 1 : _loc1_.state;
      }
      
      public static function getPlayerCrystalCount() : int
      {
         if(_questActorDictionary != null)
         {
            return _playerCrystalCount;
         }
         return 0;
      }
      
      public static function playerJumpLand() : void
      {
         var _loc2_:QuestActor = null;
         var _loc1_:int = 0;
         if(_questActorDictionary != null)
         {
            _loc1_ = 0;
            while(_loc1_ < _questActors.length)
            {
               _loc2_ = _questActors[_loc1_];
               if(_loc2_._actorData.type == 21)
               {
                  _loc2_.playerJumpLand();
               }
               _loc1_++;
            }
         }
      }
      
      public static function isSideScrollQuest() : Boolean
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         if(_inQuestRoom && _questActorDictionary != null)
         {
            _loc2_ = _roomManager.roomDefId;
            _loc1_ = RoomXtCommManager.getRoomDef(_loc2_);
            if(_loc1_ != null && _loc1_.isPlatformer == true)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getQuestActorState(param1:String) : int
      {
         var _loc2_:Object = _questActorDictionary[param1];
         if(_loc2_)
         {
            return _loc2_.state;
         }
         return -1;
      }
      
      public static function setHotColdStatus(param1:int) : void
      {
         _adventureHotColdStatus = param1;
      }
   }
}

