package room
{
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import WorldItems.WorldItemsManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.UserCommXtCommManager;
   import buddy.BuddyManager;
   import buddy.BuddyXtCommManager;
   import collection.DenStateItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.bit.BitUtility;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenStateItem;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.MinigameInfo;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gamePlayFlow.GamePlay;
   import gui.AdventureExpertPopup;
   import gui.DarkenManager;
   import gui.FeedbackManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.JBManager;
   import gui.NGFactManager;
   import gui.PetAdoptionBanner;
   import gui.PollManager;
   import gui.PredictiveTextManager;
   import gui.RecycleItems;
   import gui.ServerSelector;
   import gui.UpsellManager;
   import item.ItemXtCommManager;
   import loadProgress.LoadProgress;
   import localization.LocalizationManager;
   import pet.EggPetGuiManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   
   public class RoomManagerWorld extends RoomManagerView
   {
      private static const ROOM_SFX_MEDIA_ID:int = 1625;
      
      private static const ACTION_POINT_TYPE_MINIGAME:int = 0;
      
      private static const ACTION_POINT_TYPE_SHOP:int = 1;
      
      private static const ACTION_POINT_TYPE_NGFACT:int = 2;
      
      private static const ACTION_POINT_TYPE_POLL:int = 3;
      
      private static const ACTION_POINT_TYPE_FEEDBACK:int = 4;
      
      private static const ACTION_POINT_TYPE_QUEST_ACTOR:int = 5;
      
      private static const ACTION_POINT_TYPE_LAUNCH_QUEST:int = 6;
      
      private static const ACTION_POINT_TYPE_QUEST_RESPAWN:int = 7;
      
      public static const ROOM_MODE_AVATAR:int = 0;
      
      public static const ROOM_MODE_DEN:int = 1;
      
      public static const ROOM_MODE_CAMERAFOCUS_TO_TARGET:int = 2;
      
      public static const ROOM_MODE_CAMERAFOCUS_STAY:int = 3;
      
      public static const ROOM_MODE_CAMERAFOCUS_RETURN:int = 4;
      
      private static var _instance:RoomManagerWorld;
      
      public static var _ffmCloseCallback:Function;
      
      private static var _hasOpenedClothesShop:Boolean = false;
      
      private static var _hasOpenedDenShop:Boolean = false;
      
      private var _roomMode:int;
      
      private var _roomDefID:int;
      
      private var _roomEnviroType:int;
      
      private var _bIsMyDen:Boolean;
      
      private var _gotoUsername:String;
      
      private var _cameraFocusTimer:Number;
      
      private var _cameraFocusToTime:Number;
      
      private var _cameraFocusStayTime:Number;
      
      private var _cameraFocusReturnTime:Number;
      
      private var _cameraFocusPoint:Point;
      
      private var _cameraReturnPoint:Point;
      
      private var _cameraSpeedX:Number;
      
      private var _cameraSpeedY:Number;
      
      private var _bAttemptingToJoinMinigameRoom:Boolean;
      
      private var _lastGoodRoomName:String;
      
      private var _fullRoomSpawn:String;
      
      private var _lastPortal:Object;
      
      private var _shardId:int;
      
      public var _gotNewShardId:Boolean;
      
      private var _forceInvisMode:Boolean;
      
      private var _factDefIds:Array;
      
      private var _factDefLocs:Array;
      
      private var _denOwnerName:String;
      
      private var _denCatId:int;
      
      private var _recycle:RecycleItems;
      
      private var _bounceVolumes:Array;
      
      private var _denItems:DenItemHolder;
      
      public var _bInDenShop:Boolean;
      
      private var _dragAccelX:Number;
      
      private var _dragAccelY:Number;
      
      private var _dragX:Number;
      
      private var _dragY:Number;
      
      private var _bLastShowDenHud:Boolean;
      
      private var _callback_FFMRoomAssetsLoaded:Function;
      
      private var _callback_InitialDataRequest:Function;
      
      private var _callback_TriggerWalkIn:Function;
      
      private var _theaterLayer:Object;
      
      private var _jbItems:Array;
      
      private var _inWorldItems:Array;
      
      private var _isMasterpiecePartyRoom:Boolean;
      
      private var _shouldLoadMessagePopups:Boolean;
      
      private var _bMouseDownIgnore:Boolean;
      
      private var _bMouseDownForDenPortal:Boolean;
      
      private var _inAndOutItems:Object;
      
      private var _jamaaMS:Number = -1;
      
      private var _prevGetTimer:Number = 0;
      
      private var _customMinigameLoaderInfos:Array;
      
      private var _minigameJoinId:int;
      
      private var _needsToSeeKickFromDenMessage:Boolean;
      
      private var _needsToSeeFacilitatorMessage:Boolean;
      
      private var _facilitatorMessage:Object;
      
      private var _defaultStartupRoomName:String;
      
      private var _zoom:Number;
      
      private var _thisRoomZoom:int;
      
      private var _hasCenteredOnUser:Boolean;
      
      private var _allPreviouslyNeededRoomItems:Object;
      
      private var _currPreviewManager:Object;
      
      private var _inPreviewMode:Boolean;
      
      private var _frameTime:Number;
      
      private var _platform:Object;
      
      private var _scrollVelocity:Point;
      
      private var _scrollAcceleration:Point;
      
      public function RoomManagerWorld(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid access.  Use RoomManager.instance");
         }
      }
      
      public static function get instance() : RoomManagerWorld
      {
         if(!_instance)
         {
            _instance = new RoomManagerWorld(SingletonLock);
         }
         return _instance;
      }
      
      override public function init(param1:LayerManager) : void
      {
         super.init(param1);
         _bAttemptingToJoinMinigameRoom = false;
         _lastGoodRoomName = null;
         _defaultStartupRoomName = "jamaa_township.room_main";
         _shardId = 0;
         _gotNewShardId = false;
         _forceInvisMode = false;
         _denItems = new DenItemHolder(param1);
         gMainFrame.server.addEventListener("OnJoinRoom",onJoinRoom);
         _denOwnerName = "";
         _zoom = 100;
         _scrollVelocity = new Point(0,0);
         _scrollAcceleration = new Point(0,0);
         _customMinigameLoaderInfos = [];
         _minigameJoinId = -1;
         loadRoomEventSfx(1625);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         gMainFrame.server.removeEventListener("OnJoinRoom",onJoinRoom);
      }
      
      override public function exitRoom(param1:Boolean = false) : void
      {
         if(!_shouldLoadMessagePopups)
         {
            GuiManager.onExitRoom(false,param1);
         }
         if(gMainFrame.clientInfo.roomType == 7)
         {
            QuestManager.onExitRoom();
         }
         DarkenManager.clearDarkenList();
         RoomXtCommManager.isSwitching = false;
         super.exitRoom(param1);
         _lastPortal = null;
         if(!param1)
         {
            _denItems.release();
         }
         SBPopupManager.closeAll();
         SBPopupManager.destroyNonSBPopups();
         GenericListGuiManager.onRoomExit();
         AvatarManager.clearSpecialPatternLayer();
         if(_scene && _spawns)
         {
            if(_theaterLayer)
            {
               _theaterLayer = null;
            }
         }
         _hasCenteredOnUser = false;
         _bIsMyDen = false;
         setRoomMode(0);
         gMainFrame.stage.invalidate();
      }
      
      public function loadRoom(param1:String, param2:int, param3:int, param4:int, param5:int, param6:int, param7:Object) : void
      {
         if(param1 != "qcqNoLoad")
         {
            if(param1 == "jamaa_township.first_five")
            {
               if(_callback_FFMRoomAssetsLoaded != null)
               {
                  RoomXtCommManager._loadingNewRoom = false;
                  _callback_FFMRoomAssetsLoaded();
                  _callback_FFMRoomAssetsLoaded = null;
               }
            }
            else
            {
               _thisRoomZoom = param5;
               _roomEnviroType = param2;
               _roomDefID = param6;
               _inPreviewMode = false;
               AvatarManager.roomEnviroType = _roomEnviroType;
               loadRoom_base(param1,loadAvatarAssets);
               gMainFrame.clientInfo.roomType = param3;
               gMainFrame.clientInfo.secondaryDefId = param4;
               gMainFrame.clientInfo.customRoomData = param7;
               if(_denOwnerName != "")
               {
                  if(_denOwnerName == gMainFrame.server.userName)
                  {
                     _gaRoomName += "/owner";
                  }
                  else
                  {
                     _gaRoomName += "/stranger";
                  }
               }
               _bIsMyDen = _denOwnerName == gMainFrame.server.userName;
               DarkenManager.showLoadingSpiral(false);
               gMainFrame.stage.focus = null;
               _pathName = param1;
            }
         }
      }
      
      public function reloadCurrentNormalRoom() : void
      {
         var _loc1_:AvatarWorldView = null;
         if(_allPreviouslyNeededRoomItems)
         {
            _inPreviewMode = false;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _allPreviouslyNeededRoomItems.scale;
            _roomEnviroType = _allPreviouslyNeededRoomItems.roomEnviroType;
            resetCurrentRoom_base(_allPreviouslyNeededRoomItems.pathName);
            onRoomLoaded_base(sceneAssetsLoaded,_allPreviouslyNeededRoomItems.scene);
            denItemHolder.reloadItems();
            convertPathToWorldSpace();
            initActionPoints();
            if(AvatarManager.playerAvatarWorldView)
            {
               _loc1_ = AvatarManager.playerAvatarWorldView;
               _loc1_.roomType = _allPreviouslyNeededRoomItems.roomEnviroType;
               AvatarManager.updatePlayerAvatarViewParent(true);
               AvatarManager.resetThrottle();
               _loc1_.setSplashVolume(_allPreviouslyNeededRoomItems.isInSplash,_allPreviouslyNeededRoomItems.splashLiquid);
               _loc1_.playIdle();
               AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_allPreviouslyNeededRoomItems.pos.x,_allPreviouslyNeededRoomItems.pos.y,false,false,true);
               setRoomMode(_allPreviouslyNeededRoomItems.prevRoomMode);
            }
            _scrollOffset = _allPreviouslyNeededRoomItems.scrollOffset;
            _currPreviewManager.handleAllRequiredVisibilities(true);
            _currPreviewManager = null;
            _allPreviouslyNeededRoomItems = null;
            _layerManager.showAvatarsAndRelatedItems(true);
         }
      }
      
      public function loadPreviewRoom(param1:String, param2:int, param3:Object) : void
      {
         var _loc5_:Boolean = false;
         var _loc4_:String = null;
         var _loc6_:AvatarWorldView = null;
         var _loc7_:Point = null;
         QuestManager.privateAdventureJoinClose(true);
         MinigameManager.closeAndResetPVPAndMingameJoins();
         if(AvatarManager.playerAvatarWorldView)
         {
            _loc6_ = AvatarManager.playerAvatarWorldView;
            _loc7_ = new Point(_loc6_.avatarPos.x,_loc6_.avatarPos.y);
            _loc5_ = _loc6_.inSplashVolume();
            _loc4_ = _loc6_.splashLiquid;
            _loc6_.setSplashVolume(false,null);
            _loc6_.roomType = param2;
            _loc6_.playIdle();
         }
         _inPreviewMode = true;
         _currPreviewManager = param3;
         AvatarManager.hideAllOffscreenViews();
         _allPreviouslyNeededRoomItems = {
            "pathName":_pathName,
            "scale":_layerManager.bkg.scaleX,
            "roomEnviroType":_roomEnviroType,
            "scene":_scene.sceneObject,
            "pos":_loc7_,
            "scrollOffset":new Point(_scrollOffset.x,_scrollOffset.y),
            "isInSplash":_loc5_,
            "splashLiquid":_loc4_,
            "prevRoomMode":_roomMode
         };
         loadRoom_base(param1,loadPreviewAvatar,true);
      }
      
      public function getDarknessFromScene() : Array
      {
         var _loc1_:* = null;
         var _loc8_:int = 0;
         var _loc9_:Shape = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:int = 0;
         var _loc11_:Array = null;
         var _loc4_:Point = null;
         var _loc2_:Matrix = null;
         var _loc3_:Point = null;
         var _loc6_:Array = _volumeManager.findVolumesByType(21);
         var _loc10_:Array = [];
         for each(_loc1_ in _loc6_)
         {
            _loc9_ = new Shape();
            _loc9_.graphics.beginFill(0);
            _loc9_.graphics.moveTo(_loc1_.v[0].x,_loc1_.v[0].y);
            _loc8_ = 1;
            while(_loc8_ < _loc1_.v.length)
            {
               _loc9_.graphics.lineTo(_loc1_.v[_loc8_].x,_loc1_.v[_loc8_].y);
               _loc8_++;
            }
            _loc9_.graphics.endFill();
            _loc10_.push(_loc9_);
            _loc5_ = 20;
            _loc7_ = 2;
            _loc12_ = 1;
            if(_loc1_.message.length)
            {
               _loc11_ = _loc1_.message.split(",");
               if(_loc11_.length == 2)
               {
                  _loc12_ = int(_loc11_[0]);
                  _loc5_ = int(_loc11_[1]);
               }
            }
            _loc8_ = 0;
            while(_loc8_ < _loc12_)
            {
               _loc4_ = _loc1_.v[_loc8_].subtract(_loc1_.v[_loc8_ + 1]);
               _loc2_ = new Matrix();
               _loc2_.createGradientBox(_loc4_.length,_loc5_,-1.5707963267948966);
               _loc3_ = new Point(-_loc4_.y,_loc4_.x);
               _loc3_.normalize(1);
               _loc9_ = new Shape();
               _loc9_.graphics.beginGradientFill("linear",[0,0],[0,1],[0,255],_loc2_);
               _loc9_.graphics.drawRect(0,0,_loc4_.length,_loc5_);
               _loc9_.rotation = Math.atan2(_loc4_.y,_loc4_.x) * 180 / 3.141592653589793;
               _loc9_.x = _loc1_.v[_loc8_ + 1].x - _loc7_ * _loc3_.x;
               _loc9_.y = _loc1_.v[_loc8_ + 1].y - _loc7_ * _loc3_.y;
               _loc10_.push(_loc9_);
               _loc8_++;
            }
         }
         _loc6_ = _volumeManager.findVolumesByType(22);
         for each(_loc1_ in _loc6_)
         {
            _loc9_ = new Shape();
            _loc9_.graphics.beginFill(0);
            _loc9_.graphics.moveTo(_loc1_.v[0].x,_loc1_.v[0].y);
            _loc8_ = 1;
            while(_loc8_ < _loc1_.v.length)
            {
               _loc9_.graphics.lineTo(_loc1_.v[_loc8_].x,_loc1_.v[_loc8_].y);
               _loc8_++;
            }
            _loc9_.graphics.endFill();
            _loc10_.push(_loc9_);
         }
         return _loc10_;
      }
      
      private function loadAvatarAssets() : void
      {
         DebugUtility.debugTrace("loading self assets");
         AvatarManager.loadSelfAssets(onRoomLoaded);
         if(_bIsMyDen)
         {
            _playerGotoSpawnPoint = "myden";
         }
         if(_needsToSeeKickFromDenMessage)
         {
            _needsToSeeKickFromDenMessage = false;
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18073));
         }
         if(_needsToSeeFacilitatorMessage)
         {
            _needsToSeeFacilitatorMessage = false;
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(_facilitatorMessage.messageId,_facilitatorMessage.duration));
            _facilitatorMessage = null;
         }
      }
      
      private function loadPreviewAvatar() : void
      {
         AvatarManager.updatePlayerAvatarViewParent(false);
         _currPreviewManager.handleAllRequiredVisibilities(false);
         onPreviewRoomLoaded(null);
      }
      
      protected function onPreviewRoomLoaded(param1:*) : void
      {
         var _loc4_:Avatar = null;
         var _loc5_:AvatarWorldView = null;
         var _loc3_:Point = null;
         var _loc2_:Object = null;
         onRoomLoaded_base(sceneAssetsLoaded,null,true);
         convertPathToWorldSpace();
         initActionPoints();
         if(_gotoUsername == null || _gotoUsername == "" || (_loc4_ = AvatarManager.getAvatarByUserName(_gotoUsername)) == null || (_loc5_ = AvatarManager.avatarViewList[_loc4_.sfsUserId]) == null)
         {
            if(_playerGotoSpawnPoint == "use_player_goto_spawn_location")
            {
               _loc3_ = new Point();
               _loc2_ = {};
               _loc2_.x = _loc3_.x = _playerGotoSpawnLocationX;
               _loc2_.y = _loc3_.y = _playerGotoSpawnLocationY;
            }
            else
            {
               _loc2_ = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!_loc2_)
               {
                  _loc2_ = findSpawn(_spawns,"default");
                  if(!_loc2_)
                  {
                     _loc2_ = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               _loc3_ = getRandomRadiusOffset(_loc2_.r);
               _loc2_.x += _loc3_.x;
               _loc2_.y += _loc3_.y;
               _loc3_ = new Point(_loc2_.x,_loc2_.y);
               convertToWorldSpace(_loc3_);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            _loc3_ = new Point();
            _loc2_ = {};
            _loc2_.x = _loc3_.x = _loc5_.x;
            _loc2_.y = _loc3_.y = _loc5_.y;
            _loc2_.x += _mainBackObj.x;
            _loc2_.y += _mainBackObj.y;
            _gotoUsername = null;
         }
         _scrollOffset.x = 900 * 0.5 - _loc2_.x;
         _scrollOffset.y = 550 * 0.5 - _loc2_.y;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc3_.x,_loc3_.y,false,false);
      }
      
      protected function onRoomLoaded(param1:*) : void
      {
         var _loc4_:Point = null;
         var _loc5_:Avatar = null;
         var _loc6_:AvatarWorldView = null;
         var _loc3_:Object = null;
         if(_thisRoomZoom < _zoom)
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _thisRoomZoom / 100;
         }
         else
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _zoom / 100;
         }
         onRoomLoaded_base(sceneAssetsLoaded,null);
         _denCatId = !!_roomSettings.denCatId ? _roomSettings.denCatId : -1;
         convertPathToWorldSpace();
         initActionPoints();
         var _loc2_:Object = findSpawn(_spawns,"den_theme");
         if(_loc2_)
         {
            _denItems.setThemePosition(_loc2_.x,_loc2_.y);
         }
         if(_denOwnerName != "")
         {
            DenXtCommManager.denChangeDone();
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + _gotoUsername);
            if(_gotoUsername != null)
            {
               DebugUtility.debugTrace("onRoomLoaded - (jumpAv = AvatarManager.getAvatarByUserName(_gotoUsername)) == null:" + ((_loc5_ = AvatarManager.getAvatarByUserName(_gotoUsername)) == null));
            }
            DebugUtility.debugTrace("onRoomLoaded - jumpAv:" + _loc5_);
            if(_loc5_ != null)
            {
               DebugUtility.debugTrace("onRoomLoaded - (jumpToAv = AvatarManager.avatarViewList[jumpAv.sfsUserId]) == null:" + ((_loc6_ = AvatarManager.avatarViewList[_loc5_.sfsUserId]) == null));
            }
            DebugUtility.debugTrace("onRoomLoaded - jumpToAv:" + _loc6_);
         }
         if(_gotoUsername == null || _gotoUsername == "" || (_loc5_ = AvatarManager.getAvatarByUserName(_gotoUsername)) == null || (_loc6_ = AvatarManager.avatarViewList[_loc5_.sfsUserId]) == null)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoSpawnPoint:" + _playerGotoSpawnPoint);
            if(_playerGotoSpawnPoint == "use_player_goto_spawn_location")
            {
               _loc4_ = new Point();
               _loc3_ = {};
               _loc3_.x = _loc4_.x = _playerGotoSpawnLocationX;
               _loc3_.y = _loc4_.y = _playerGotoSpawnLocationY;
            }
            else
            {
               _loc3_ = findSpawn(_spawns,_playerGotoSpawnPoint);
               if(!_loc3_)
               {
                  _loc3_ = findSpawn(_spawns,"default");
                  if(!_loc3_)
                  {
                     _loc3_ = {
                        "x":400,
                        "y":400,
                        "r":10,
                        "toSpawn":null
                     };
                  }
               }
               _loc4_ = getRandomRadiusOffset(_loc3_.r);
               _loc3_.x += _loc4_.x;
               _loc3_.y += _loc4_.y;
               _loc4_ = new Point(_loc3_.x,_loc3_.y);
               convertToWorldSpace(_loc4_);
            }
            _playerGotoSpawnPoint = "default";
         }
         else
         {
            DebugUtility.debugTrace("onRoomLoaded - pos:" + _loc4_);
            _loc4_ = new Point();
            _loc3_ = {};
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn:" + _loc3_ + " pos:" + _loc4_ + " jumpToAv:" + _loc6_);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.x:" + _loc3_.x + " pos.x:" + _loc4_.x + " jumpToAv.x:" + _loc6_.x);
            DebugUtility.debugTrace("onRoomLoaded - b4 spawn.y:" + _loc3_.y + " pos.y:" + _loc4_.y + " jumpToAv.y:" + _loc6_.y);
            _loc3_.x = _loc4_.x = _loc6_.x;
            _loc3_.y = _loc4_.y = _loc6_.y;
            DebugUtility.debugTrace("onRoomLoaded - mainBackObj offset spawn:" + _loc3_ + " _mainBackObj:" + _mainBackObj);
            _loc3_.x += _mainBackObj.x;
            _loc3_.y += _mainBackObj.y;
            DebugUtility.debugTrace("onRoomLoaded - after spawn:" + _loc3_ + " pos:" + _loc4_ + " jumpToAv:" + _loc6_);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.x:" + _loc3_.x + " pos.x:" + _loc4_.x + " jumpToAv.x:" + _loc6_.x);
            DebugUtility.debugTrace("onRoomLoaded - after spawn.y:" + _loc3_.y + " pos.y:" + _loc4_.y + " jumpToAv.y:" + _loc6_.y);
            _gotoUsername = null;
            DebugUtility.debugTrace("onRoomLoaded - set null _gotoUsername:" + _gotoUsername);
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("onRoomLoaded - _gotoUsername:" + _gotoUsername + " jumpAv:" + _loc5_);
         }
         _scrollOffset.x = 900 * 0.5 - _loc3_.x;
         _scrollOffset.y = 550 * 0.5 - _loc3_.y;
         AvatarManager.playerAvatarWorldView.playAnim(_roomEnviroType == 0 ? 14 : 32);
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc4_.x,_loc4_.y,true,false);
         QuestManager.checkQuestOffScreenUsers();
         AvatarSwitch.playerInfoSet();
         _bTestPortal = true;
         if(_loc3_.toSpawn != null)
         {
            walkToSpawn(_loc3_.toSpawn);
         }
         GuiManager.onEnterRoom(_roomEnviroType);
         GuiManager.activateDenHud(_bIsMyDen);
         GuiManager.showHudAvt();
         if(!gMainFrame.userInfo.playerUserInfo.denItemsFull)
         {
            DenXtCommManager.requestDenItems(null);
         }
         if(_shouldLoadMessagePopups)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["lw"]);
            }
         }
         if(_minigameJoinId != -1)
         {
            MinigameManager.handleGameClick({"typeDefId":_minigameJoinId},null);
            _minigameJoinId = -1;
         }
         if(QuestManager.isSideScrollQuest())
         {
            _platform = _scene.getLayer("platform1");
         }
      }
      
      private function initActionPoints() : void
      {
         var _loc7_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:Point = null;
         var _loc14_:Array = null;
         var _loc13_:Array = null;
         var _loc6_:Array = null;
         var _loc15_:Array = null;
         var _loc10_:Array = null;
         var _loc4_:Array = null;
         var _loc8_:Array = null;
         var _loc3_:* = null;
         var _loc2_:MovieClip = null;
         var _loc9_:Loader = null;
         var _loc1_:int = 0;
         var _loc5_:Array = [];
         if(_actionPoints != null)
         {
            _loc14_ = [];
            _loc13_ = [];
            _loc6_ = [];
            _loc15_ = [];
            _loc10_ = [];
            _loc4_ = [];
            _loc8_ = [];
            _loc7_ = 0;
            while(_loc7_ < _actionPoints.length)
            {
               switch((_loc11_ = _actionPoints[_loc7_]).type)
               {
                  case 0:
                     if(!MinigameManager.minigameInfoCache.getMinigameInfo(_loc11_.typeDefId))
                     {
                        _loc5_.push(_loc11_.typeDefId);
                        break;
                     }
                     _loc2_ = new MinigameManager.GameTotem() as MovieClip;
                     if(MinigameManager.minigameInfoCache.getMinigameInfo(_loc11_.typeDefId).petDefId > 0)
                     {
                        _loc9_ = _loc2_.getChildAt(0) as Loader;
                        _loc9_.contentLoaderInfo.addEventListener("complete",onPetGameTotemLoaded);
                        _customMinigameLoaderInfos.push(_loc9_.contentLoaderInfo);
                     }
                     if(MinigameManager.minigameInfoCache.getMinigameInfo(_loc11_.typeDefId).gameDefId == 88)
                     {
                        _loc9_ = _loc2_.getChildAt(0) as Loader;
                        _loc9_.contentLoaderInfo.addEventListener("complete",onSafetyGameTotemLoaded);
                        _customMinigameLoaderInfos.push(_loc9_.contentLoaderInfo);
                     }
                     _loc12_ = new Point(_loc11_.x - _loc2_.width * 0.5,_loc11_.y - _loc2_.height);
                     convertToWorldSpace(_loc12_);
                     _loc2_.x = _loc12_.x;
                     _loc2_.y = _loc12_.y;
                     _layerManager.room_orbs.addChild(_loc2_);
                     _loc3_ = _loc2_;
                     break;
                  case 1:
                     _loc1_ = 60;
                     _loc12_ = new Point(_loc11_.x - _loc1_,_loc11_.y - _loc1_);
                     convertToWorldSpace(_loc12_);
                     _loc11_.pos = _loc12_;
                     _loc11_.rad = _loc1_;
                     break;
                  case 2:
                     _loc12_ = new Point(_loc11_.x,_loc11_.y);
                     convertToWorldSpace(_loc12_);
                     _loc13_[_loc11_.typeDefId] = _loc12_;
                     _loc14_.push(_loc11_.typeDefId);
                     break;
                  case 3:
                     _loc12_ = new Point(_loc11_.x,_loc11_.y);
                     convertToWorldSpace(_loc12_);
                     _loc15_[_loc11_.typeDefId] = _loc12_;
                     _loc6_.push(_loc11_.typeDefId);
                     _loc10_[_loc11_.typeDefId] = _loc11_.params == "" ? 1 : _loc11_.params;
                     break;
                  case 4:
                     _loc12_ = new Point(_loc11_.x,_loc11_.y);
                     convertToWorldSpace(_loc12_);
                     _loc8_[_loc11_.typeDefId] = _loc12_;
                     _loc4_.push(_loc11_.typeDefId);
                     break;
                  case 6:
                     _loc2_ = new MinigameManager.GameTotem() as MovieClip;
                     _loc12_ = new Point(_loc11_.x - _loc2_.width * 0.5,_loc11_.y - _loc2_.height);
                     convertToWorldSpace(_loc12_);
                     _loc2_.x = _loc12_.x;
                     _loc2_.y = _loc12_.y;
                     _layerManager.room_orbs.addChild(_loc2_);
                     _loc3_ = _loc2_;
                     break;
                  case 5:
                     if(_loc11_.hasOwnProperty("name"))
                     {
                        _loc12_ = new Point(_loc11_.x,_loc11_.y);
                        convertToWorldSpace(_loc12_);
                        QuestManager.initQuestActor(_loc11_.name,_loc11_.r,_loc11_.r2,null,_loc12_,null,true,_loc11_.params);
                     }
                     break;
                  case 7:
                     _loc12_ = new Point(_loc11_.x,_loc11_.y);
                     convertToWorldSpace(_loc12_);
                     _loc11_.pos = _loc12_;
                     break;
                  default:
                     throw new Error("Actionpoint type is not valid!");
               }
               _loc11_.idx = _loc7_;
               if(_loc3_)
               {
                  _loc3_.addEventListener("mouseDown",onMouseDownEvt_ActionPoint,false,0,true);
                  _loc3_.addEventListener("rollOver",onMouseOverEvt_ActionPoint,false,0,true);
                  _loc3_.addEventListener("rollOut",onMouseOutEvt_ActionPoint,false,0,true);
                  _loc11_.clip = _loc3_;
               }
               _loc7_++;
            }
            if(_loc14_.length > 0)
            {
               _factDefIds = _loc14_;
               _factDefLocs = _loc13_;
               if(_factDefIds && _factDefLocs)
               {
                  NGFactManager.requestFactInfo(_loc14_,_loc13_);
               }
            }
            if(_loc6_.length > 0 && gMainFrame.userInfo.numLogins >= 3)
            {
               PollManager.setUpPolls(_loc6_,_loc15_,_loc10_);
            }
            if(_loc4_.length > 0)
            {
               FeedbackManager.setUpOrbs(_loc4_,_loc8_);
            }
         }
         if(_volumes)
         {
            _loc7_ = 0;
            while(_loc7_ < _volumes.length)
            {
               _loc11_ = _volumes[_loc7_];
               var _loc16_:* = _loc11_.type;
               if(1 === _loc16_)
               {
                  _loc11_.idx = _loc7_;
                  if(!MinigameManager.minigameInfoCache.getMinigameInfo(_loc11_.typeDefId))
                  {
                     _loc5_.push(_loc11_.typeDefId);
                  }
               }
               _loc7_++;
            }
         }
         if(_loc5_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc5_,false,setupMinigameActionPoints);
         }
      }
      
      public function setupMinigameActionPoints() : void
      {
         var _loc6_:Object = null;
         var _loc2_:Point = null;
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:MinigameInfo = null;
         var _loc1_:MovieClip = null;
         var _loc7_:Loader = null;
         if(!_actionPoints || _actionPoints.length <= 0)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < _actionPoints.length)
         {
            _loc6_ = _actionPoints[_loc5_];
            if(_loc6_.type == 0)
            {
               _loc4_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc6_.typeDefId);
               if(!_loc4_)
               {
                  return;
               }
               _loc1_ = new MinigameManager.GameTotem() as MovieClip;
               _loc2_ = new Point(_loc6_.x - _loc1_.width * 0.5,_loc6_.y - _loc1_.height);
               convertToWorldSpace(_loc2_);
               if(_loc4_.petDefId > 0)
               {
                  _loc7_ = _loc1_.getChildAt(0) as Loader;
                  _loc7_.contentLoaderInfo.addEventListener("complete",onPetGameTotemLoaded);
                  _customMinigameLoaderInfos.push(_loc7_.contentLoaderInfo);
               }
               if(_loc4_.gameDefId == 88)
               {
                  _loc7_ = _loc1_.getChildAt(0) as Loader;
                  _loc7_.contentLoaderInfo.addEventListener("complete",onSafetyGameTotemLoaded);
                  _customMinigameLoaderInfos.push(_loc7_.contentLoaderInfo);
               }
               _loc1_.x = _loc2_.x;
               _loc1_.y = _loc2_.y;
               _layerManager.room_orbs.addChild(_loc1_);
               _loc3_ = _loc1_;
               _loc3_.addEventListener("mouseDown",onMouseDownEvt_ActionPoint,false,0,true);
               _loc3_.addEventListener("rollOver",onMouseOverEvt_ActionPoint,false,0,true);
               _loc3_.addEventListener("rollOut",onMouseOutEvt_ActionPoint,false,0,true);
               _loc6_.clip = _loc3_;
            }
            _loc5_++;
         }
      }
      
      private function onPetGameTotemLoaded(param1:Event) : void
      {
         var _loc4_:LoaderInfo = null;
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ < _customMinigameLoaderInfos.length)
         {
            _loc4_ = _customMinigameLoaderInfos[_loc3_];
            if(!(!_loc4_ || _loc4_ != LoaderInfo(param1.target)))
            {
               _customMinigameLoaderInfos.splice(_loc3_,1);
               _loc2_ = _loc4_.loader.content as MovieClip;
               _loc2_.gotoAndPlay("petController");
               break;
            }
            _loc3_++;
         }
      }
      
      private function onSafetyGameTotemLoaded(param1:Event) : void
      {
         var _loc4_:LoaderInfo = null;
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ < _customMinigameLoaderInfos.length)
         {
            _loc4_ = _customMinigameLoaderInfos[_loc3_];
            if(!(!_loc4_ || _loc4_ != LoaderInfo(param1.target)))
            {
               _customMinigameLoaderInfos.splice(_loc3_,1);
               _loc2_ = _loc4_.loader.content as MovieClip;
               _loc2_.gotoAndPlay("safetyquiz");
               break;
            }
            _loc3_++;
         }
      }
      
      public function onNormalFactPopupsReady() : void
      {
         if(_factDefIds && _factDefLocs)
         {
            NGFactManager.requestFactInfo(_factDefIds,_factDefLocs);
            _factDefIds = null;
            _factDefLocs = null;
         }
      }
      
      public function onJourneyBookFactDefReceived(param1:Object, param2:int, param3:int) : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc8_:Boolean = false;
         var _loc5_:String = null;
         var _loc7_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _jbItems.length)
         {
            _loc4_ = _jbItems[_loc6_];
            if(_loc4_.refId == param1.id && (_loc4_.refObjName == "" || _loc4_.refObjName.indexOf("start") == 0))
            {
               _loc8_ = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx));
               if(_loc8_)
               {
                  _jbItems.splice(_loc6_--,1);
               }
               else
               {
                  _loc4_.isReady = true;
               }
               _loc5_ = _loc4_.refObjName;
               while(_loc5_ != "" && _loc5_ != "end")
               {
                  if(_loc5_.indexOf("start") == 0)
                  {
                     _loc5_ = _loc5_.substr(6);
                     if(_loc8_)
                     {
                        _loc4_.s.content.visible = true;
                        if(_loc4_.s.content.hasOwnProperty("critter"))
                        {
                           _loc4_.s.content.critter.visible = true;
                        }
                     }
                  }
                  _loc4_ = getJourneyBookItem(_loc5_);
                  if(_loc8_)
                  {
                     _loc7_ = 0;
                     while(_loc7_ < _jbItems.length)
                     {
                        if(_jbItems[_loc7_].refId == _loc4_.refId)
                        {
                           _jbItems.splice(_loc7_--,1);
                        }
                        _loc7_++;
                     }
                     _loc4_.s.content.visible = true;
                  }
                  else
                  {
                     _loc4_.isReady = true;
                  }
                  _loc5_ = _loc4_.refObjName;
               }
               break;
            }
            _loc6_++;
         }
         JBManager.checkUnseenPage(_jbItems);
      }
      
      public function playMusic(param1:String, param2:Number) : void
      {
         playMusicTrack(param1,param2);
      }
      
      public function playPreviousMusic() : void
      {
         playPreviousMusicTrack();
      }
      
      public function playOriginalMusic(param1:String, param2:Number) : void
      {
         tryToPlayOriginalTrack(param1,param2);
      }
      
      override protected function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc15_:Boolean = false;
         var _loc18_:Array = null;
         var _loc16_:Object = null;
         var _loc13_:Object = null;
         var _loc5_:Boolean = false;
         var _loc14_:int = 0;
         var _loc2_:Object = null;
         var _loc10_:int = 0;
         var _loc3_:String = null;
         var _loc11_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:Array = null;
         var _loc12_:Object = null;
         super.sceneAssetsLoaded(param1);
         _jbItems = [];
         _inWorldItems = [];
         _inAndOutItems = {};
         _isMasterpiecePartyRoom = false;
         var _loc19_:Array = [];
         if(gMainFrame.server.getCurrentRoom().name.indexOf("party") >= 0)
         {
            _loc15_ = true;
            _loc16_ = PartyManager.getPartyDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc16_ && _loc16_.id == 47)
            {
               _isMasterpiecePartyRoom = true;
               _loc18_ = [];
            }
         }
         _loc10_ = 0;
         while(_loc10_ < _layers.length)
         {
            _loc13_ = _layers[_loc10_];
            if(_loc13_.typeIndex == 1)
            {
               _loc5_ = true;
               if(_loc13_.s.content.hasOwnProperty("randomAppear"))
               {
                  _loc5_ = Boolean(_loc13_.s.content.randomAppear());
               }
               if(_loc5_)
               {
                  _loc13_.s.content.isJBItem = true;
               }
               _jbItems.push(_loc13_);
            }
            if(_loc13_.typeIndex == 1 || _loc13_.typeIndex == 2)
            {
               if(_loc13_.delaySecs && !isNaN(_loc13_.delaySecs) && _loc13_.s.content.hasOwnProperty("playAnim"))
               {
                  if(_loc13_.typeIndex == 2 && _loc13_.offsetSecs != null && !isNaN(_loc13_.offsetSecs))
                  {
                     _loc14_ = int(_loc13_.offsetSecs);
                  }
                  else
                  {
                     _loc14_ = _loc13_.delaySecs / 2;
                  }
                  _inAndOutItems[_loc10_] = [];
                  while(_loc14_ <= 3600)
                  {
                     _inAndOutItems[_loc10_].push(_loc14_);
                     _loc14_ += _loc13_.delaySecs;
                  }
               }
            }
            else if(_loc13_.name.indexOf("bottle_") != -1)
            {
               _inWorldItems[int(_loc13_.name.substring(7))] = _loc13_;
            }
            if(!_scene._useDynamicLoading && _loc13_.layer == 1)
            {
               if(_loc13_.s.hasOwnProperty("content") && _loc13_.s.content.hasOwnProperty("getSortHeight"))
               {
                  _loc13_.s.name = _loc13_.s.content.getSortHeight();
               }
            }
            if(_loc13_.name.indexOf("portalon") != -1)
            {
               _loc19_.push(_loc13_);
            }
            if(_isMasterpiecePartyRoom && _loc13_.name.indexOf("mp_") != -1)
            {
               _loc18_.push(_loc13_);
            }
            _loc10_++;
         }
         var _loc6_:Array = [];
         _loc10_ = 0;
         while(_loc10_ < _jbItems.length)
         {
            _loc2_ = _jbItems[_loc10_];
            _loc2_.isReady = false;
            _loc3_ = _loc2_.refObjName;
            if(_loc3_ == "" || _loc3_.indexOf("start") == 0)
            {
               _loc6_.push(_loc2_.refId);
            }
            else
            {
               _loc2_.s.content.visible = false;
            }
            _loc10_++;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc6_.length)
         {
            NGFactManager.requestJourneyBookFactDef(_loc6_[_loc11_],onJourneyBookFactDefReceived);
            _loc11_++;
         }
         if(_loc15_)
         {
            if(_loc6_.length > 0)
            {
               _loc7_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(366));
               _loc8_ = int(AchievementXtCommManager.UV_PARTY_JB_ENTER_BIT_ARRAY.indexOf(gMainFrame.clientInfo.secondaryDefId));
               if(_loc7_ == -1 || (_loc7_ >> _loc8_ & 1) == 0)
               {
                  GuiManager.openJourneyBook(gMainFrame.clientInfo.secondaryDefId);
                  AchievementXtCommManager.requestSetUserVar(366,_loc8_);
               }
            }
            if(_isMasterpiecePartyRoom && _loc18_.length > 0)
            {
               PartyManager.setupMasterpiecesInRoom(_loc18_);
            }
         }
         else if(_inWorldItems && _inWorldItems.length > 0)
         {
            WorldItemsManager.requestWorldItemDefs(_inWorldItems);
         }
         var _loc4_:Object = _scene.getLayer("movie_player_streaming");
         if(_loc4_ && _loc4_.loader && _loc4_.loader.content)
         {
            _theaterLayer = _loc4_.loader.content;
         }
         else
         {
            _theaterLayer = null;
         }
         if(_theaterLayer)
         {
            _theaterLayer.subtitle.text = "";
            _theaterLayer.grayBox.visible = false;
            _loc9_ = _scene.getActorList("ActorVolume");
            for each(var _loc17_ in _loc9_)
            {
               if(_loc17_.name == "movieselector")
               {
                  _loc12_ = null;
                  if(_loc17_.message != "")
                  {
                     _loc12_ = {};
                     _loc12_.msg = _loc17_.message;
                  }
                  GenericListXtCommManager.requestStreamList(_loc17_.typeDefId,GenericListGuiManager.launchMovies,_loc12_);
                  break;
               }
            }
         }
         _bounceVolumes = _volumeManager.findVolume("bouncevolume");
         disableAvatarBounce();
         if(_callback_InitialDataRequest != null)
         {
            _callback_InitialDataRequest();
            _callback_InitialDataRequest = null;
         }
         QuestManager.sceneAssetsLoaded(_loc19_);
         GuiManager.reconnecting = false;
         RoomXtCommManager.loadingNewRoom = false;
         if(_callback_FFMRoomAssetsLoaded != null)
         {
            _callback_FFMRoomAssetsLoaded();
            _callback_FFMRoomAssetsLoaded = null;
         }
         gMainFrame.stage.invalidate();
         if(!_scene._useDynamicLoading)
         {
            setTimeout(LoadProgress.show,41.666666666666664,false);
         }
      }
      
      public function broadcastMute(param1:Boolean) : void
      {
         if(_persistentObject)
         {
            _persistentObject.muteChanged(param1);
         }
         QuestManager.muteChanged(param1);
      }
      
      public function teleportPlayer(param1:int, param2:int, param3:Boolean) : void
      {
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,param1,param2,true,false,true);
         if(param3)
         {
            scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),34285.71428571428,_frameTime);
         }
         forceStopMovement();
      }
      
      public function teleportPlayerToDefault() : void
      {
         var _loc1_:Object = findSpawn(_spawns,_playerGotoSpawnPoint);
         if(!_loc1_)
         {
            _loc1_ = findSpawn(_spawns,"default");
            if(!_loc1_)
            {
               _loc1_ = {
                  "x":400,
                  "y":400,
                  "r":10,
                  "toSpawn":null
               };
            }
         }
         var _loc2_:Point = getRandomRadiusOffset(_loc1_.r);
         _loc1_.x += _loc2_.x;
         _loc1_.y += _loc2_.y;
         _loc2_ = new Point(_loc1_.x,_loc1_.y);
         convertToWorldSpace(_loc2_);
         _playerGotoSpawnPoint = "default";
         teleportPlayer(_loc2_.x,_loc2_.y,true);
      }
      
      public function setGotoUsername(param1:String, param2:Boolean) : void
      {
         var _loc3_:AvatarWorldView = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:Avatar = null;
         DebugUtility.debugTrace("setGotoUsername - value:" + param1 + " alreadyInRoom:" + param2);
         if(!param2 || (_loc5_ = AvatarManager.getAvatarByUserName(param1)) == null)
         {
            _gotoUsername = param1;
         }
         else
         {
            _loc3_ = AvatarManager.avatarViewList[_loc5_.sfsUserId];
            _loc4_ = _loc3_.x;
            _loc6_ = _loc3_.y;
            _scrollOffset.x = 900 / 2 - (_loc4_ + _mainBackObj.x);
            _scrollOffset.y = 550 / 2 - (_loc6_ + _mainBackObj.y);
            AvatarManager.resetThrottle();
            AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,_loc4_,_loc6_,true,false);
         }
         DebugUtility.debugTrace("setGotoUsername - _gotoUsername:" + _gotoUsername + " gotoAv:" + _loc5_);
      }
      
      public function modGotoUser(param1:String, param2:int, param3:int) : void
      {
         DebugUtility.debugTrace("modGotoUser - _gotoUsername:" + _gotoUsername + " acUserName:" + param1);
         if(_gotoUsername == null || param1 != _gotoUsername)
         {
            return;
         }
         _gotoUsername = null;
         AvatarManager.resetThrottle();
         AvatarManager.updateAvatar(AvatarManager.playerSfsUserId,param2,param3,true,false);
      }
      
      private function onMouseDownEvt_ActionPoint(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_bTestPortal && _actionPoints)
         {
            for each(var _loc2_ in _actionPoints)
            {
               if(_loc2_.type == 0)
               {
                  if(_loc2_.clip == param1.currentTarget)
                  {
                     if(QuestManager.isInPrivateAdventureState)
                     {
                        QuestManager.showLeaveQuestLobbyPopup(onMouseDownEvt_ActionPoint,param1);
                        return;
                     }
                     if(!RoomXtCommManager.isSwitching)
                     {
                        GuiManager.toolTip.resetTimerAndSetVisibility();
                        _playerGotoSpawnPoint = _loc2_.spawn;
                        MinigameManager.handleGameClick(_loc2_,onFrgJoined);
                        AJAudio.playSubMenuBtnClick();
                     }
                     break;
                  }
               }
               else if(_loc2_.type == 6)
               {
                  if(_loc2_.clip == param1.currentTarget)
                  {
                     checkAndStartAdventure(_loc2_.typeDefId);
                  }
               }
            }
         }
      }
      
      private function onMouseOverEvt_ActionPoint(param1:MouseEvent) : void
      {
         AJAudio.playSubMenuBtnRollover();
         for each(var _loc2_ in _actionPoints)
         {
            if(_loc2_.type == 0)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,MinigameManager.getGameName(_loc2_.typeDefId),_loc2_.clip.x + 50,_loc2_.clip.y + 80);
                  GuiManager.toolTip.startTimer(param1);
                  break;
               }
            }
            else if(_loc2_.type == 6)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1.5,1.5,1.5);
                  GuiManager.toolTip.init(_layerManager.room_orbs,LocalizationManager.translateIdOnly(14679),_loc2_.clip.x + 50,_loc2_.clip.y + 80);
                  GuiManager.toolTip.startTimer(param1);
                  break;
               }
            }
         }
      }
      
      private function onMouseOutEvt_ActionPoint(param1:MouseEvent) : void
      {
         for each(var _loc2_ in _actionPoints)
         {
            if(_loc2_.type == 0)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
            else if(_loc2_.type == 6)
            {
               if(_loc2_.clip == param1.currentTarget)
               {
                  GuiManager.toolTip.resetTimerAndSetVisibility();
                  MovieClip(_loc2_.clip).transform.colorTransform = new ColorTransform(1,1,1);
                  break;
               }
            }
         }
      }
      
      public function checkAndStartAdventure(param1:int, param2:Boolean = false) : void
      {
         var _loc6_:Object = null;
         var _loc4_:AvatarInfo = null;
         var _loc5_:Object = null;
         var _loc3_:Object = RoomXtCommManager.getRoomDef(roomDefId);
         if(_loc3_ == null)
         {
            return;
         }
         if(_loc3_.pathName.indexOf("queststaging_433") != -1)
         {
            if(!QuestManager.canGoInPlatformAdventure(param1,param2))
            {
               return;
            }
         }
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(checkAndStartAdventure,param1,param2);
            return;
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(!RoomXtCommManager.isSwitching)
         {
            _loc6_ = QuestXtCommManager.getScriptDef(param1);
            if(_loc6_.membersOnly && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("adventures","adventure/" + param1,null,null,param2);
               return;
            }
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(!_loc4_)
            {
               return;
            }
            if(_loc6_.playAsPet)
            {
               _loc5_ = PetManager.myActivePet;
               if(!_loc5_)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  return;
               }
               if(!PetManager.canPetGoInEnviroType(_loc5_.currPetDef,_loc5_.createdTs,_loc6_.avatarType))
               {
                  switch(_loc6_.avatarType)
                  {
                     case 1:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19648));
                        break;
                     case 2:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19649));
                        break;
                     case 4:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19650));
                        break;
                     case 5:
                        new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19655));
                  }
                  return;
               }
            }
            if(AvatarManager.playerAvatar && !AvatarManager.isValidEnviro(_loc6_.avatarType))
            {
               switch(_loc6_.avatarType)
               {
                  case 1:
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                     break;
                  case 2:
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                     break;
                  case 4:
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                     break;
                  case 5:
               }
               return;
            }
            if(_loc6_.restrictions == 1 && BitUtility.bitwiseAnd(_loc6_.avatarDefFlags,BitUtility.leftShiftNumbers(AvatarManager.playerAvatar.avTypeId - 1)) == 0)
            {
               GuiManager.showBarrierPopup(1,true,false,_loc6_.defId);
               return;
            }
            if(_loc4_.questLevel < _loc6_.levelMin)
            {
               if(!param2)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc6_.levelMin));
               }
               else
               {
                  new SBOkPopup(gMainFrame.stage,LocalizationManager.translateIdAndInsertOnly(14697,_loc6_.levelMin),false);
               }
               return;
            }
            if(_loc6_.avatarLimit == 1 && _loc6_.time != 1)
            {
               if(_loc6_.hudType == 1)
               {
                  if(param1 == 39)
                  {
                     GuiManager.isInFFM = true;
                  }
                  QuestXtCommManager.sendQuestCreateJoinPublic(param1);
                  return;
               }
               if(!param2)
               {
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14825),true,onConfirmStartAdventure,param1);
                  return;
               }
            }
            if(_loc6_.time == 1)
            {
               QuestManager.openAdventureJoin(_loc6_.defId,"noPlayers",0);
               return;
            }
            AdventureExpertPopup.init(param1,param2);
         }
      }
      
      private function onConfirmStartAdventure(param1:Object) : void
      {
         if(param1.status)
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(param1.passback);
         }
      }
      
      public function getNearestQuestRespawnPointPlayerIsIn(param1:Point) : Object
      {
         var _loc4_:* = NaN;
         var _loc5_:* = null;
         var _loc3_:Number = NaN;
         if(_actionPoints != null)
         {
            _loc5_ = null;
            for each(var _loc2_ in _actionPoints)
            {
               if(_loc2_.type == 7)
               {
                  _loc3_ = (param1.x - _loc2_.pos.x) * (param1.x - _loc2_.pos.x) + (param1.y - _loc2_.pos.y) * (param1.y - _loc2_.pos.y);
                  if(_loc3_ < _loc2_.r2 * _loc2_.r2 && (_loc5_ == null || _loc3_ < _loc4_))
                  {
                     _loc5_ = _loc2_;
                     _loc4_ = _loc3_;
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public function setRoomMode(param1:int) : void
      {
         if(_roomMode == 1)
         {
            if(param1 == 0)
            {
               KeepAlive.stopKATimer(gMainFrame.stage);
               _denItems.saveState();
            }
            _bLastShowDenHud = true;
         }
         else if(_roomMode == 0 && param1 == 1)
         {
            KeepAlive.startKATimer(gMainFrame.stage);
         }
         if(param1 == 2)
         {
            if(_cameraFocusToTime <= 0)
            {
               param1 = 3;
               _scrollOffset = _cameraFocusPoint;
               updateBackground();
            }
         }
         if(param1 == 3)
         {
            if(_cameraFocusStayTime <= 0)
            {
               param1 = 4;
            }
         }
         switch(param1 - 2)
         {
            case 0:
               _cameraFocusTimer = 0;
               _cameraSpeedX = (_cameraFocusPoint.x - _scrollOffset.x) / _cameraFocusToTime;
               _cameraSpeedY = (_cameraFocusPoint.y - _scrollOffset.y) / _cameraFocusToTime;
               break;
            case 1:
               _cameraFocusTimer = 0;
               _cameraSpeedX = 0;
               _cameraSpeedY = 0;
               break;
            case 2:
               _cameraFocusTimer = 0;
               _cameraSpeedX = (_cameraReturnPoint.x - _scrollOffset.x) / _cameraFocusReturnTime;
               _cameraSpeedY = (_cameraReturnPoint.y - _scrollOffset.y) / _cameraFocusReturnTime;
         }
         _roomMode = param1;
         _denItems.setRoomMode(_roomMode);
      }
      
      public function setCameraFocus(param1:Point, param2:Number, param3:Number, param4:Number, param5:Boolean) : void
      {
         forceStopMovement();
         _cameraReturnPoint = new Point(_scrollOffset.x,_scrollOffset.y);
         if(param5)
         {
            _cameraFocusPoint = new Point(900 / 2 - (param1.x + _mainBackObj.x),550 / 2 - (param1.y + _mainBackObj.y));
         }
         else
         {
            _cameraFocusPoint = param1;
         }
         _cameraFocusToTime = param2;
         _cameraFocusStayTime = param3;
         _cameraFocusReturnTime = param4;
         setRoomMode(2);
      }
      
      public function spawnNewDenItem(param1:DenStateItem) : void
      {
         var _loc2_:Point = null;
         _loc2_ = convertScreenToWorldSpace(450,275);
         param1.x = _loc2_.x;
         param1.y = _loc2_.y;
         var _loc3_:DenStateItemCollection = new DenStateItemCollection();
         _loc3_.pushDenStateItem(param1);
         _denItems.setItems(_loc3_,true);
      }
      
      public function forceStopMovement() : void
      {
         killPlayerPath();
         if(AvatarManager.playerAvatarWorldView)
         {
            AvatarManager.movePlayer(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
         }
      }
      
      public function get denItemHolder() : DenItemHolder
      {
         return _denItems;
      }
      
      public function get denCatId() : int
      {
         return _denCatId;
      }
      
      public function get shardId() : int
      {
         return _shardId;
      }
      
      public function get forceInvisMode() : Boolean
      {
         return _forceInvisMode;
      }
      
      public function get theaterWindow() : Object
      {
         return _theaterLayer;
      }
      
      public function get roomEnviroType() : int
      {
         return _roomEnviroType;
      }
      
      public function get roomDefId() : int
      {
         return _roomDefID;
      }
      
      public function set shardId(param1:int) : void
      {
         var _loc3_:* = null;
         var _loc2_:String = null;
         _shardId = param1;
         var _loc4_:GamePlay = GamePlay(gMainFrame.gamePlay);
         if(_loc4_ != null)
         {
            _loc3_ = "[Not Initialized]";
            _loc2_ = ServerSelector.getShardName(param1);
            if(_loc2_)
            {
               _loc3_ = _loc2_;
            }
            _loc4_.debugShardIdTxt = param1 + " | " + _loc3_ + " | " + LocalizationManager.localeForNumberFormatting;
         }
      }
      
      public function set forceInvisMode(param1:Boolean) : void
      {
         _forceInvisMode = param1;
      }
      
      public function set callback_TriggerWalkIn(param1:Function) : void
      {
         _callback_TriggerWalkIn = param1;
      }
      
      public function set callback_FFMRoomAssetsLoaded(param1:Function) : void
      {
         _callback_FFMRoomAssetsLoaded = param1;
      }
      
      public function set callback_InitialDataRequest(param1:Function) : void
      {
         _callback_InitialDataRequest = param1;
      }
      
      public function set needsToSeeKickFromDenMessage(param1:Boolean) : void
      {
         _needsToSeeKickFromDenMessage = param1;
      }
      
      public function setNeedsToSeeFacilitatorMessage(param1:Boolean, param2:int, param3:int = 0) : void
      {
         _needsToSeeFacilitatorMessage = true;
         _facilitatorMessage = {
            "messageId":param2,
            "duration":param3
         };
      }
      
      private function onFrgJoined() : void
      {
      }
      
      public function get inPreviewMode() : Boolean
      {
         return _inPreviewMode;
      }
      
      public function get isMyDen() : Boolean
      {
         return _bIsMyDen;
      }
      
      public function get denOwnerName() : String
      {
         return _denOwnerName;
      }
      
      public function updateRoomZoom(param1:int) : void
      {
         _zoom = param1;
         _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = param1 / 100;
         _hasCenteredOnUser = false;
         var _loc2_:Number = Math.ceil(Math.max(900 / (_stageMax.x - _stageMin.x + 900),550 / (_stageMax.y - _stageMin.y + 550)) * 100) / 100;
         _loc2_ += _loc2_ * 0.1;
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         if(_loc2_ > _layerManager.bkg.scaleX)
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _loc2_;
         }
         super.setupBuckets();
      }
      
      public function heartbeat(param1:int, param2:int, param3:Number) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Boolean = true;
         switch(_roomMode)
         {
            case 0:
               heartbeat_avatar(param1);
               break;
            case 1:
               heartbeat_den(param1);
               break;
            case 2:
               _loc5_ = false;
               _cameraFocusTimer += param1 * 0.001;
               if(_cameraFocusTimer >= _cameraFocusToTime)
               {
                  setRoomMode(3);
                  break;
               }
               _scrollOffset.x += _cameraSpeedX * param1 * 0.001;
               _scrollOffset.y += _cameraSpeedY * param1 * 0.001;
               updateBackground();
               break;
            case 3:
               _loc5_ = false;
               _cameraFocusTimer += param1 * 0.001;
               if(_cameraFocusTimer >= _cameraFocusStayTime)
               {
                  setRoomMode(4);
               }
               break;
            case 4:
               _loc5_ = false;
               _cameraFocusTimer += param1 * 0.001;
               if(_cameraFocusTimer >= _cameraFocusReturnTime)
               {
                  setRoomMode(0);
                  break;
               }
               _scrollOffset.x += _cameraSpeedX * param1 * 0.001;
               _scrollOffset.y += _cameraSpeedY * param1 * 0.001;
               updateBackground();
               break;
         }
         updateSocialVolumes();
         updateSplashVolumes();
         updateLayerActors(param3);
         if(_bounceVolumes != null && QuestManager.isSideScrollQuest() == false)
         {
            updateAvatarBounce();
         }
         if(_loc5_ && AvatarManager.playerAvatar && AvatarManager.playerAvatarWorldView)
         {
            _loc4_ = _volumeManager.testAvatarVolumes(new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y));
            if(_loc4_)
            {
               if(_loc4_.type == 6)
               {
                  AvatarManager.setPlayerAttachmentEmot(_loc4_.typeDefId,null,2);
               }
               else if(_loc4_.type == 11)
               {
                  if(_callback_TriggerWalkIn != null)
                  {
                     _callback_TriggerWalkIn(_loc4_.message);
                  }
               }
            }
            _loc5_ = heartbeat_movePlayer(param1,param2);
         }
         if(_inPreviewMode)
         {
            _layerManager.preview_room_avatar.heartbeat();
            _layerManager.preview_room_flying_avatar.heartbeat();
         }
         else
         {
            _layerManager.room_avatars.heartbeat();
            _layerManager.flying_avatars.heartbeat();
         }
         if(_bMouseDownNew)
         {
            _bMouseDownNew = false;
         }
         _frameTime = param2 / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         var _loc6_:Number = 1;
         if(QuestManager.isSideScrollQuest())
         {
            _loc6_ = 32 / 24;
         }
         if(_roomMode == 0 && (_loc5_ || !_hasCenteredOnUser) && AvatarManager.playerAvatarWorldView && _mainBackObj)
         {
            _hasCenteredOnUser = scrollRoom(AvatarManager.playerAvatarWorldView.localToGlobal(new Point(0,0)),24 * _loc6_ * _frameTime / 0.07,_frameTime);
         }
      }
      
      public function testBounceVolumes(param1:Point) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc2_:* = null;
         if(_bounceVolumes != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _bounceVolumes.length)
            {
               _loc4_ = _bounceVolumes[_loc3_];
               if(_volumeManager.testPointInVolume(param1,_bounceVolumes[_loc3_]))
               {
                  _loc2_ = _loc4_;
                  break;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      private function updateAvatarBounce() : void
      {
         var _loc1_:* = undefined;
         var _loc2_:Object = AvatarManager.avatarViewList;
         for(var _loc3_ in _loc2_)
         {
            _loc1_ = _loc2_[_loc3_];
            if(_volumeManager.testPointInVolume(new Point(_loc1_.x,_loc1_.y),_bounceVolumes[0]))
            {
               _loc1_.setBounce(true);
            }
            else
            {
               _loc1_.setBounce(false);
            }
         }
      }
      
      private function disableAvatarBounce() : void
      {
         var _loc1_:Object = AvatarManager.avatarViewList;
         for(var _loc2_ in _loc1_)
         {
            _loc1_[_loc2_].setBounce(false);
         }
      }
      
      private function heartbeat_den(param1:int) : void
      {
         var _loc2_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc3_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(_bMouseMove || _dragAccelX > 0 || _dragAccelY > 0)
         {
            if(!_bInDenShop)
            {
               _loc4_ = _mousePos.x;
               _loc5_ = _mousePos.y;
               if(_mousePos.x < 0)
               {
                  _loc4_ = 0;
               }
               else if(_mousePos.x > 900)
               {
                  _loc4_ = 900;
               }
               if(_mousePos.y < 0)
               {
                  _loc5_ = 0;
               }
               else if(_mousePos.y > 550)
               {
                  _loc5_ = 550;
               }
               if(_bMouseDown)
               {
                  if(_denItems.isDragging)
                  {
                     _loc9_ = 100;
                     _loc10_ = 75;
                     if(_mousePos.x < _loc9_)
                     {
                        _loc8_ = 1;
                        _loc3_ = (_mousePos.x - _loc9_) / -_loc9_;
                     }
                     else if(_mousePos.x > 900 - _loc9_)
                     {
                        _loc8_ = -1;
                        _loc3_ = (900 - _loc9_ - _mousePos.x) / -_loc9_;
                     }
                     if(_mousePos.y < _loc10_)
                     {
                        _loc6_ = 1;
                        _loc7_ = (_mousePos.y - _loc10_) / -_loc10_;
                     }
                     else if(_mousePos.y > 550 - 120 - _loc10_)
                     {
                        _loc6_ = -1;
                        _loc7_ = (550 - 120 - _loc10_ - _mousePos.y) / -_loc10_;
                     }
                     if(_loc8_ != 0 || _loc6_ != 0)
                     {
                        _loc3_ *= 12;
                        if(_loc3_ > 12)
                        {
                           _loc3_ = 12;
                        }
                        _loc7_ *= 12;
                        if(_loc7_ > 12)
                        {
                           _loc7_ = 12;
                        }
                        _dragAccelX += 0.75;
                        if(_dragAccelX > _loc3_)
                        {
                           _dragAccelX = _loc3_;
                        }
                        _dragAccelY += 0.75;
                        if(_dragAccelY > _loc7_)
                        {
                           _dragAccelY = _loc7_;
                        }
                        _scrollOffset.x += _loc8_ * _dragAccelX;
                        _scrollOffset.y += _loc6_ * _dragAccelY;
                        updateBackground();
                     }
                     else
                     {
                        _dragAccelX = 0;
                        _dragAccelY = 0;
                     }
                  }
                  else
                  {
                     if(_dragX != -999)
                     {
                        _loc8_ = _dragX - _mousePos.x;
                        _loc6_ = _dragY - _mousePos.y;
                        if(_loc8_ != 0 || _loc6_ != 0)
                        {
                           _scrollOffset.x -= _loc8_;
                           _scrollOffset.y -= _loc6_;
                           updateBackground();
                        }
                     }
                     _dragX = _mousePos.x;
                     _dragY = _mousePos.y;
                  }
               }
               else
               {
                  _dragAccelX = 0;
                  _dragAccelY = 0;
                  _dragX = -999;
               }
               _loc2_ = convertScreenToWorldSpace(_loc4_,_loc5_);
               _denItems.handleMouse(_loc2_.x,_loc2_.y,_bMouseDown);
            }
            _bMouseMove = false;
         }
         showDenHud(!(_denItems.isDragging && _bMouseDown));
      }
      
      public function heartbeat_avatar(param1:int) : Boolean
      {
         var _loc7_:Object = null;
         var _loc5_:DisplayObjectContainer = null;
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc3_:String = null;
         var _loc2_:Object = null;
         if(_bMouseMove)
         {
            clickVolumeTest(_mousePos);
         }
         if(_bMouseDownNew && _bMouseDownIgnore)
         {
            _bMouseDownIgnore = false;
         }
         if(_bMouseDownNew)
         {
            if(_isMasterpiecePartyRoom)
            {
               PartyManager.handleMasterpieceClick(getObjUnderPoint(_mousePos,_layerManager.room_bkg,true));
            }
            else
            {
               if(_jbItems && _jbItems.length > 0)
               {
                  _loc5_ = _layerManager.bkg;
                  _loc7_ = getObjUnderPoint(_mousePos,_loc5_,true,true);
                  if(_loc7_)
                  {
                     _loc6_ = 0;
                     while(_loc6_ < _jbItems.length)
                     {
                        _loc4_ = _jbItems[_loc6_];
                        if(_loc4_.s.content == _loc7_)
                        {
                           _loc7_ = getObjUnderPoint(_mousePos,_loc5_);
                           if(_loc7_)
                           {
                              forceStopMovement();
                              _bMouseDownNew = false;
                              _bMouseDownIgnore = true;
                              if(_loc4_.isReady)
                              {
                                 _jbItems.splice(_loc6_,1);
                                 if(_loc4_.refObjName == "" || _loc4_.refObjName == "end")
                                 {
                                    NGFactManager.showJourneyBookFact(_loc4_.refId);
                                    break;
                                 }
                                 _loc3_ = _loc4_.refObjName;
                                 if(_loc3_.indexOf("start") == 0)
                                 {
                                    _loc3_ = _loc3_.substr(6);
                                 }
                                 if(_loc4_.s.content.hasOwnProperty("playAnim"))
                                 {
                                    _loc4_.s.content.playAnim();
                                 }
                                 _loc2_ = getJourneyBookItem(_loc3_);
                                 _loc2_.s.content.visible = true;
                                 _loc2_.s.content.playAnim();
                              }
                           }
                           break;
                        }
                        _loc6_++;
                     }
                  }
               }
               if(_inWorldItems && _inWorldItems.length > 0)
               {
                  _loc7_ = getObjUnderPoint(_mousePos,_layerManager.room_bkg,true);
                  if(_loc7_)
                  {
                     WorldItemsManager.onItemDown(_loc7_);
                  }
               }
            }
            if(_denOwnerName != "")
            {
               if(_denItems.shouldStopMovement(_mousePos))
               {
                  _bMouseDownIgnore = true;
               }
            }
         }
         if(!_bMouseDownIgnore)
         {
            followCursorTest();
         }
         portalCollisionTest();
         return false;
      }
      
      private function updateLayerActors(param1:Number) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_jamaaMS <= -1)
         {
            return;
         }
         if(!_layers)
         {
            _jamaaMS += param1 - _prevGetTimer;
            _prevGetTimer = param1;
            return;
         }
         var _loc6_:Number = _jamaaMS + (param1 - _prevGetTimer);
         for(var _loc5_ in _inAndOutItems)
         {
            _loc2_ = _inAndOutItems[_loc5_];
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(_jamaaMS * 0.001 % 3600 < _loc2_[_loc4_] && _loc6_ * 0.001 % 3600 >= _loc2_[_loc4_])
               {
                  if(_layers[_loc5_] && _layers[_loc5_].s && _layers[_loc5_].s.content)
                  {
                     _layers[_loc5_].s.content.playAnim();
                  }
               }
               _loc4_++;
            }
         }
         _prevGetTimer = param1;
         _jamaaMS = _loc6_;
      }
      
      public function set jamaaMilliseconds(param1:Number) : void
      {
         _jamaaMS = param1;
         _prevGetTimer = getTimer();
      }
      
      private function showDenHud(param1:Boolean) : void
      {
         if(_bLastShowDenHud != param1)
         {
            _bLastShowDenHud = param1;
            GuiManager.showDenHudItems(param1);
         }
      }
      
      public function getNumJBItemsLeftInWorld() : int
      {
         return _jbItems.length;
      }
      
      private function getJourneyBookItem(param1:String) : Object
      {
         var _loc2_:int = 0;
         param1 = param1.toLowerCase();
         _loc2_ = 0;
         while(_loc2_ < _jbItems.length)
         {
            if(_jbItems[_loc2_].name == param1)
            {
               return _jbItems[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getObjUnderPoint(param1:Point, param2:DisplayObjectContainer, param3:Boolean = false, param4:Boolean = false) : Object
      {
         var _loc7_:int = 0;
         var _loc5_:Array = param2.getObjectsUnderPoint(param1);
         var _loc6_:int = int(_loc5_.length);
         if(_loc6_ > 0)
         {
            _loc7_ = _loc6_ - 1;
            while(_loc7_ >= 0)
            {
               if(fullHitTest(_loc5_[_loc7_].root,param1,param3,param4))
               {
                  return _loc5_[_loc7_].root;
               }
               _loc7_--;
            }
         }
         return null;
      }
      
      public function fullHitTest(param1:DisplayObject, param2:Point, param3:Boolean, param4:Boolean) : Boolean
      {
         var _loc6_:BitmapData = null;
         var _loc5_:Boolean = false;
         if(param1)
         {
            if(param1 is MovieClip || param3 || param4)
            {
               if(param4)
               {
                  if(!param1.hasOwnProperty("isJBItem"))
                  {
                     return false;
                  }
               }
               return param1.hitTestPoint(param2.x,param2.y,param3);
            }
            try
            {
               _loc6_ = new BitmapData(param1.width,param1.height,true,0);
               _loc6_.draw(param1,new Matrix());
               _loc5_ = _loc6_.hitTest(new Point(0,0),0,param1.globalToLocal(param2));
               _loc6_.dispose();
               return _loc5_;
            }
            catch(e:Error)
            {
               trace("Security sandbox violation caught or BitmapData invalid");
            }
            return false;
         }
         return false;
      }
      
      private function clickVolumeTest(param1:Point) : void
      {
         var _loc7_:Array = null;
         var _loc4_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Array = null;
         var _loc8_:RoomObject = null;
         var _loc2_:Object = null;
         var _loc6_:Array = null;
         var _loc3_:Object = null;
         var _loc11_:int = 0;
         if(!_volumes)
         {
            return;
         }
         param1 = convertScreenToWorldSpace(param1.x,param1.y);
         var _loc5_:Object = _volumeManager.testMouseVolumes(param1,_bMouseDown);
         if(_loc5_ && _bMouseDownNew)
         {
            loop0:
            switch(_loc5_.type)
            {
               case 1:
                  if(!inPreviewMode)
                  {
                     MinigameManager.handleGameClick(_loc5_,onFrgJoined,_loc5_.typeDefId == 51 ? false : true,null,0,true);
                  }
                  break;
               case 3:
                  if(_ffmCloseCallback != null)
                  {
                     _ffmCloseCallback();
                     _hasOpenedClothesShop = true;
                  }
                  break;
               case 4:
                  if(_ffmCloseCallback != null)
                  {
                     _ffmCloseCallback();
                     _hasOpenedDenShop = true;
                  }
                  break;
               case 7:
                  switch((_loc7_ = _loc5_.message.split("%"))[0])
                  {
                     case "museum":
                        NGFactManager.requestMuseumFactInfo(_loc7_);
                        break loop0;
                     case "donation":
                        GuiManager.openMuseumDonation();
                        break loop0;
                     case "jammercentral":
                        GuiManager.openJammerCentral();
                        break loop0;
                     case "ebook":
                        GuiManager.openEBookChooser(_loc7_[1]);
                        break loop0;
                     case "pet":
                        PetManager.openPetFinder(_loc7_[1],null,false,null,null,0,0,_loc7_.length > 2 ? _loc7_[2] == "true" : false);
                        break loop0;
                     case "fact":
                        NGFactManager.showTierneyFact(_loc7_[1]);
                        break loop0;
                     case "factbrady":
                        NGFactManager.showBradyFact(_loc7_[1]);
                        break loop0;
                     case "carni":
                        DarkenManager.showLoadingSpiral(true);
                        PartyXtCommManager.sendJoinPartyRequest(18);
                        break loop0;
                     case "photobooth":
                        GuiManager.openPhotoBooth();
                        break loop0;
                     case "ajeventfact":
                        if(_loc7_.length > 2)
                        {
                           NGFactManager.requestFactInfoByList(_loc7_);
                           break loop0;
                        }
                        NGFactManager.requestFactInfo([_loc7_[1]]);
                        break loop0;
                     case "diamondinfo":
                        GuiManager.openDiamondShopInfo();
                        break loop0;
                     case "adventure":
                        checkAndStartAdventure(_loc7_[1]);
                        break loop0;
                     case "displayimages":
                        GuiManager.openDisplayImagesPopup();
                        break loop0;
                     case "petbanner":
                        PetAdoptionBanner.init(_loc7_[1]);
                        break loop0;
                     case "party":
                        if(_loc7_[1] == "47")
                        {
                           QuestManager.showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(28913).split("|"),2052,-1,true,PartyXtCommManager.sendJoinPartyRequest,_loc7_[1]);
                           break loop0;
                        }
                        PartyXtCommManager.sendJoinPartyRequest(_loc7_[1]);
                        break loop0;
                     case "eggpet":
                        EggPetGuiManager.openEggPetPurchasePopup();
                        break loop0;
                     case "comic":
                        GuiManager.openPageFlipBook(_loc7_[1],true,3);
                  }
                  break;
               case 8:
                  if(_ffmCloseCallback != null && _hasOpenedClothesShop)
                  {
                     _ffmCloseCallback();
                  }
                  launchRecycle(0);
                  break;
               case 9:
                  if(_ffmCloseCallback != null && _hasOpenedDenShop)
                  {
                     _ffmCloseCallback();
                  }
                  launchRecycle(1);
                  break;
               case 12:
                  _loc4_ = gMainFrame.userInfo.getGenericListDefByDefId(_loc5_.typeDefId);
                  if(_loc4_)
                  {
                     _loc9_ = {};
                     _loc9_.volName = _loc5_.name;
                     if(_loc4_.typeId == 1037)
                     {
                        if(_loc5_.message != "")
                        {
                           _loc9_ = {};
                           _loc10_ = _loc5_.message.split("|");
                           if(_loc10_.length > 1)
                           {
                              _loc9_.msg = _loc10_[0];
                              _loc9_.width = _loc10_[1];
                              _loc9_.height = _loc10_[2];
                              _loc9_.shouldRepeat = _loc10_[3] != null && _loc10_[3] == "true" ? true : false;
                           }
                           else
                           {
                              _loc9_.msg = _loc5_.message;
                           }
                        }
                        _theaterLayer = _scene.getLayer("movie_player_streaming");
                     }
                     GenericListGuiManager.genericListVolumeClicked(_loc5_.typeDefId,_loc9_);
                  }
                  break;
               case 13:
                  AvatarManager.setPlayerAttachmentEmot(_loc5_.typeDefId,_loc5_.message,1440);
                  break;
               case 24:
                  if(_loc5_.message == "")
                  {
                     _loc8_ = _loc5_.interactiveObjs[0];
                     _loc2_ = Utility.findItemWithEvent(_loc8_.mc);
                     if(_loc2_)
                     {
                        _loc2_.mc.dispatchEvent(new MouseEvent(_loc2_.type));
                     }
                     break;
                  }
                  _loc6_ = _loc5_.message.split("%");
                  if(_loc6_.length >= 2)
                  {
                     if(_loc6_[0] == "game")
                     {
                        _loc3_ = {"typeDefId":_loc6_[1]};
                        MinigameManager.handleGameClick(_loc3_,null);
                        break;
                     }
                     if(_loc6_[0] == "list")
                     {
                        _loc11_ = 0;
                        if(_loc6_[2] == "true" || _loc6_[2] == "false")
                        {
                           if(_loc6_[2] == "true")
                           {
                              _loc11_ = 1;
                           }
                           else
                           {
                              _loc11_ = 2;
                           }
                        }
                        else
                        {
                           _loc11_ = int(_loc6_[2]);
                        }
                        GuiManager.openPageFlipBook(_loc6_[1],_loc6_[2] == "true",_loc11_);
                     }
                  }
                  break;
            }
            _volumeManager.clearHold(true);
            if(_bMouseDown && _loc5_.bWalkTo == false)
            {
               _bMouseDown = false;
            }
         }
      }
      
      private function launchRecycle(param1:int) : void
      {
         if(_recycle)
         {
            _recycle.destroy();
         }
         _recycle = new RecycleItems();
         _recycle.init(param1,GuiManager.guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
      }
      
      public function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
      }
      
      public function chosenLoginFinished() : void
      {
         if(_mainBackObj == null)
         {
            if(!gMainFrame.userInfo.avtDefsCached)
            {
               if(ItemXtCommManager.itemDefsHaveLoaded)
               {
                  if(PetXtCommManager.canLoadPetList)
                  {
                     PetXtCommManager.sendPetListRequest(gMainFrame.server.userName);
                  }
                  else
                  {
                     PetXtCommManager.canLoadPetList = true;
                  }
                  if(!gMainFrame.userInfo.needFastPass)
                  {
                     AvatarXtCommManager.requestAvatarList([gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
                  }
                  AvatarXtCommManager.requestAvatarInfo(setUpWorldJoin);
                  DenXtCommManager.requestDenRoomList();
                  JBManager.init();
                  MinigameXtCommManager.sendMinigameInfoRequest([52]);
                  if(gMainFrame.userInfo.sgChatType == 2 || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG || !PredictiveTextManager.hasRequestDictionaryBlob && LocalizationManager.accountLanguage != LocalizationManager.LANG_ENG)
                  {
                     PredictiveTextManager.resetDictionaryBlob();
                  }
                  GenericListXtCommManager.requestGenericList(10,ECardManager.onCardsLoaded);
                  GenericListXtCommManager.requestGenericList(44,ECardManager.onStampsLoaded);
               }
               else
               {
                  ItemXtCommManager.functionToCallWhenDefsLoaded = chosenLoginFinished;
               }
            }
            else if(ItemXtCommManager.itemDefsHaveLoaded)
            {
               setUpWorldJoin();
            }
            else
            {
               ItemXtCommManager.functionToCallWhenDefsLoaded = chosenLoginFinished;
            }
         }
      }
      
      public function reconnectNodeSwitchLoginFinished() : void
      {
         if(_mainBackObj != null)
         {
            throw new Error("reconnecting/switching servers while still in a room?!");
         }
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            throw new Error("missing avatarOffsets and defs while reconnecting/switching servers!");
         }
         if(gMainFrame.userInfo.playerUserInfo == null)
         {
            AvatarXtCommManager.requestAvatarList([gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
         }
         setUpWorldJoin();
      }
      
      public function setUpWorldJoin() : void
      {
         AvatarUtility.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarSwitch.getNumNonMemberAvailableAvatars,true,setupWorldJoinAfterAvatarListLoaded);
      }
      
      private function setupWorldJoinAfterAvatarListLoaded() : void
      {
         if(gMainFrame.userInfo.needFastPass)
         {
            AvatarSwitch.playerInfoSet();
            AvatarSwitch.addFastPassAvatar(null);
         }
         else if(gMainFrame.userInfo.firstFiveMinutes <= 0)
         {
            GuiManager.startFFM();
         }
         else
         {
            _gotNewShardId = true;
            joinNewShardRoom();
         }
      }
      
      public function minigameJoinRoom(param1:String) : void
      {
         _bAttemptingToJoinMinigameRoom = true;
         RoomXtCommManager.sendRoomJoinRequest(param1,-1,true);
      }
      
      public function setMinigameIdToJoin(param1:int) : void
      {
         _minigameJoinId = param1;
      }
      
      public function haveHadLastGoodRoomName() : Boolean
      {
         return _lastGoodRoomName != null;
      }
      
      public function clearLastGoodRoomForServerSwitch() : void
      {
         _lastGoodRoomName = null;
      }
      
      public function joinNewShardRoom(param1:RoomJoinType = null) : void
      {
         if(!_gotNewShardId)
         {
            trace("ERROR: joinNewShardRoom was called before we gotNewShardId!");
            return;
         }
         DebugUtility.debugTrace("joinNewShardRoom called");
         _gotNewShardId = false;
         var _loc2_:String = null;
         if(gMainFrame.clientInfo.hasOwnProperty("autoStartRoom") && gMainFrame.clientInfo.autoStartRoom != null && gMainFrame.clientInfo.autoStartRoom != "")
         {
            _loc2_ = gMainFrame.clientInfo.autoStartRoom;
            if(_loc2_ == "adventure&")
            {
               gMainFrame.server.joinDefaultRoom();
               gMainFrame.stage.focus = null;
               AvatarManager.loadSelfAssets(questRoomJoinCompleteAutoJoin);
               return;
            }
            DebugUtility.debugTrace("got autoStartRoom:" + _loc2_ + " (shardId:" + gMainFrame.clientInfo.autoStartRoomShardId + ") - sending roomjoin request...");
            if(gMainFrame.clientInfo.autoStartRoomShardId == -1)
            {
               DenXtCommManager.requestDenJoinFull(_loc2_);
               return;
            }
            if(gMainFrame.clientInfo.autoStartRoomShardId == -3)
            {
               BuddyXtCommManager.sendBuddyRoomRequest(_loc2_,seekBuddyAutoStartRoomComplete);
               return;
            }
            if(gMainFrame.clientInfo.autoStartRoomShardId == -4)
            {
               PartyXtCommManager.sendCustomPartyJoinRequest(gMainFrame.clientInfo.autoStartRoom);
               return;
            }
         }
         else
         {
            _loc2_ = _defaultStartupRoomName + "#" + _shardId;
         }
         DebugUtility.debugTrace("newJoinRoomNameOrId before sendNonDenRoomJoinRequest:" + _loc2_);
         RoomXtCommManager.sendRoomJoinRequest(_loc2_,-1,false,false,true,param1);
      }
      
      private function seekBuddyAutoStartRoomComplete(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc5_:String = null;
         var _loc4_:int = 0;
         if(param3 || param1 == null || param1 == "" || param1 == "Unknown" || param1.slice(0,5) == "quest" || param1.slice(0,3) == "ffm" || param2 == null || param2 == "" || param2 == "Choosing Server" || param2 == LocalizationManager.translateIdOnly(11235))
         {
            _loc5_ = "#-1";
            _loc4_ = int(param1.indexOf("#"));
            if(_loc4_ >= 0)
            {
               _loc5_ = param1.substr(_loc4_);
            }
            param1 = _defaultStartupRoomName + _loc5_;
         }
         else
         {
            RoomXtCommManager._joiningBuddyCrossNode = true;
         }
         RoomXtCommManager.sendRoomJoinRequest(param1,-1,false,false,true,RoomJoinType.DIRECT_JOIN_AND_SEARCH_ON_FAILURE);
      }
      
      private function questRoomJoinCompleteAutoJoin(param1:*) : void
      {
         GuiManager.reconnecting = false;
         RoomXtCommManager.loadingNewRoom = false;
         DarkenManager.showLoadingSpiral(false);
         LoadProgress.show(false);
         gMainFrame.stage.invalidate();
         checkAndStartAdventure(gMainFrame.clientInfo.autoStartRoomShardId,true);
      }
      
      private function onJoinRoom(param1:SFEvent) : void
      {
         var _loc6_:String = null;
         var _loc2_:String = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:MovieClip = null;
         if(param1.status)
         {
            if(ServerSelector.isOpen())
            {
               ServerSelector.destroy();
            }
            GuiManager.closeAvtSwitcherFromRoomJoin();
            if(_bAttemptingToJoinMinigameRoom)
            {
               _bAttemptingToJoinMinigameRoom = false;
            }
            _loc6_ = param1.obj.room.name;
            if(_loc6_.slice(0,7) != "quest_0")
            {
               _loc2_ = _loc6_.slice(0,3);
               _loc4_ = int(_loc6_.indexOf("first_five"));
               if((_lastGoodRoomName == null || _lastGoodRoomName.slice(0,3) == "ffm") && _loc2_ != "ffm" && _loc4_ == -1)
               {
                  _shouldLoadMessagePopups = true;
               }
               if(!param1.obj.subRoom)
               {
                  AvatarManager.removeAllAvatars();
                  _lastGoodRoomName = _loc6_;
                  if(_loc2_ == "den")
                  {
                     _denOwnerName = _loc6_.slice(3);
                  }
                  else
                  {
                     _denOwnerName = "";
                     _loc3_ = int(_loc6_.indexOf("#"));
                     if(_loc3_ != -1)
                     {
                        _loc5_ = int(_loc6_.substring(_loc3_ + 1));
                        if(_loc5_ != _shardId)
                        {
                           DebugUtility.debugTrace("joinedShard:" + _loc5_ + " is different than current _shardId:" + _shardId + "... updating _shardId to match.");
                           shardId = _loc5_;
                        }
                     }
                  }
                  if(AvatarManager.playerSfsUserId == -1)
                  {
                     GuiManager.chatHist.showChatInput(true);
                  }
                  if(_loc6_.indexOf("oceans") == 0)
                  {
                     gMainFrame.userInfo.worldMapRoomName = _loc6_.slice(7,_loc6_.indexOf("#"));
                  }
                  else
                  {
                     gMainFrame.userInfo.worldMapRoomName = _loc6_.slice(0,_loc6_.indexOf("."));
                  }
               }
            }
         }
         else
         {
            if(param1.obj.roomFull)
            {
               DebugUtility.debugTrace("Room was full- show room popup? _bAttemptingToJoinMinigameRoom:" + _bAttemptingToJoinMinigameRoom + " RoomXtCommManager.isSwitching:" + RoomXtCommManager.isSwitching + " _lastGoodRoomName:" + _lastGoodRoomName + " gMainFrame.server.getCurrentRoomName():" + gMainFrame.server.getCurrentRoomName());
               if(!RoomXtCommManager.isSwitching && !_bAttemptingToJoinMinigameRoom && _lastGoodRoomName != null && _lastGoodRoomName == gMainFrame.server.getCurrentRoomName())
               {
                  DebugUtility.debugTrace("Room is full!");
                  DarkenManager.showLoadingSpiral(false);
                  SBTracker.push();
                  _loc6_ = RoomXtCommManager._joinRoomName;
                  _loc6_ = _loc6_.slice(0,_loc6_.indexOf("#"));
                  if(isNaN(Number(_loc6_)))
                  {
                     SBTracker.trackPageview("/game/play/popup/joinFullRoom/#" + _loc6_,-1,1);
                  }
                  else
                  {
                     SBTracker.trackPageview("/game/play/popup/joinFullRoom",-1,1);
                  }
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14826),true,roomFullOkBtnHandler);
                  if(ServerSelector.isOpen())
                  {
                     ServerSelector.updatePopulationForRoomFullError();
                  }
               }
               else if(RoomXtCommManager.isSwitching)
               {
                  DebugUtility.debugTrace("All rooms for that animal type are full! Try again or reload and choose a different world.");
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14827),true,roomFullOkBtnHandler);
                  RoomXtCommManager.isSwitching = false;
               }
               else if(ServerSelector.isOpen())
               {
                  LoadProgress.show(false);
                  DarkenManager.showLoadingSpiral(false);
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14693),true);
                  ServerSelector.updatePopulationForRoomFullError();
               }
               else
               {
                  new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14828),false);
               }
            }
            else if(param1.message == "OA")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14829),true,GuiManager.switchToOceanAnimal,{
                  "switchRooms":true,
                  "switchDens":false
               });
            }
            else if(param1.message == "DP")
            {
               DarkenManager.showLoadingSpiral(false);
               _loc7_ = GETDEFINITIONBYNAME("DenLockedPopupContent");
               new SBPopup(GuiManager.guiLayer,GETDEFINITIONBYNAME("DenLockedPopupSkin"),_loc7_,true,true,false,false,true);
               if(param1.obj.denOwner != "" && BuddyManager.isBuddy(param1.obj.denOwner.toLowerCase()))
               {
                  LocalizationManager.translateId(_loc7_.bodyTxt1,19101);
               }
               BuddyManager.grayOutGoToDenBtn(true,param1.obj.denOwner);
            }
            else if(param1.message == "DUA")
            {
               DarkenManager.showLoadingSpiral(false);
               if(GuiManager.isVersionPopupOpen())
               {
                  BuddyManager.destroyBuddyCard();
               }
               else
               {
                  BuddyManager.resetBuddyCardForArchiveMode(RoomXtCommManager._joinRoomName.toLowerCase());
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14830),true);
               }
            }
            else if(param1.message == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a quest that does not belong to us!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14831),true);
            }
            else if(param1.message == "RDNE")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Tried to join a room that no longer exists!");
               QuestManager.handleRDNE();
            }
            else if(param1.message == "JWD")
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("Joined a room that was being destroyed!");
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14832),true,roomFullOkBtnHandler);
               RoomXtCommManager.sendRoomJoinRequest(_lastGoodRoomName);
            }
            else if(param1.message == "DG")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14833),true,roomFullOkBtnHandler);
               BuddyManager.grayOutGoToDenBtn(true);
            }
            else if(param1.message == "HAS")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18535),true);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               DebugUtility.debugTrace("got unknown join room error!");
            }
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.joiningNewRoom = false;
         }
      }
      
      override protected function onSceneLoadComplete() : void
      {
         LoadProgress.show(false);
         if(_shouldLoadMessagePopups)
         {
            _shouldLoadMessagePopups = false;
            if(gMainFrame.clientInfo.redemptionCode != undefined && gMainFrame.clientInfo.redemptionCode != "")
            {
               GuiManager.openCodeRedemptionPopup(GuiManager.initMessagePopups);
            }
            else
            {
               GuiManager.initMessagePopups();
            }
         }
      }
      
      private function roomFullOkBtnHandler(param1:MouseEvent) : void
      {
         walkToSpawn(_fullRoomSpawn);
         if(param1.currentTarget.parent.text.text == LocalizationManager.translateIdOnly(14826))
         {
            SBTracker.flush(true);
         }
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
      }
      
      private function portalCollisionTest() : void
      {
         var _loc3_:Boolean = false;
         var _loc1_:* = null;
         var _loc2_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(_bMouseDownNew)
         {
            _bMouseDownForDenPortal = true;
         }
         if(!_bTestPortal || !AvatarManager.playerAvatarWorldView || !AvatarManager.playerAvatarWorldView.moving)
         {
            return;
         }
         if(_portals)
         {
            _loc2_ = new Point();
            for each(_loc1_ in _portals)
            {
               if(!AvatarManager.playerAvatarWorldView)
               {
                  continue;
               }
               _loc2_.x = _loc1_.x;
               _loc2_.y = _loc1_.y;
               convertToWorldSpace(_loc2_);
               if(!AvatarManager.playerAvatarWorldView.circleTest(_loc2_.x,_loc2_.y,_loc1_.r))
               {
                  continue;
               }
               if(_lastPortal == _loc1_)
               {
                  _loc3_ = true;
                  continue;
               }
               _bTestPortal = false;
               _loc4_ = 0;
               if(_loc1_.type)
               {
                  _loc4_ = int(_loc1_.type);
               }
               switch(_loc4_)
               {
                  case 0:
                     _loc5_ = String(_loc1_["goto"]).toLowerCase() + "#" + _shardId;
                     DarkenManager.showLoadingSpiral(true);
                     RoomXtCommManager.sendNonDenRoomJoinRequest(_loc5_);
                     _playerGotoSpawnPoint = _loc1_.spawn;
                     _fullRoomSpawn = _loc1_.fullSpawn;
                     _lastPortal = _loc1_;
                     _loc3_ = true;
                     break;
                  case 1:
                     if(!(AvatarManager.playerAvatarWorldView.avatarData.enviroTypeFlag & 1 << 2))
                     {
                        if(RoomManagerWorld.instance.collisionTestGrid(_loc2_.x,_loc2_.y) == 0)
                        {
                           UserCommXtCommManager.sendAvatarSlide(_loc1_["goto"]);
                           attachAvatarToSlide(AvatarManager.playerAvatarWorldView,_loc1_["goto"],_loc1_.spawn);
                           if(_loc1_["goto"] == "bounceslide1")
                           {
                              SBAudio.playCachedSound("aj_slideBounce2");
                           }
                           if(_loc1_["goto"] == "bounceslide2")
                           {
                              SBAudio.playCachedSound("aj_slideBounce1");
                           }
                        }
                        else
                        {
                           _lastPortal = _loc1_;
                           _loc3_ = true;
                        }
                     }
                     break;
               }
            }
         }
         if(!_loc3_)
         {
            _lastPortal = null;
            _denItems.portalItemTest(_bMouseDownForDenPortal,_mousePos);
            _bMouseDownForDenPortal = false;
         }
      }
      
      public function getCellDiameter() : int
      {
         return _roomGrid.getCellDiameter();
      }
      
      public function findClosestOpenGridCell(param1:Number, param2:Number, param3:Boolean = true) : Object
      {
         var _loc4_:Object = _roomGrid.findClosestOpenGridCell(param1 + _mainBackObj.x,param2 + _mainBackObj.y,param3);
         _loc4_.x = _loc4_.x - _mainBackObj.x;
         _loc4_.y -= _mainBackObj.y;
         return _loc4_;
      }
      
      public function getNearestEmptyCell(param1:Number, param2:Number) : Object
      {
         return _roomGrid.getNearestEmptyCell(param1,param2);
      }
      
      public function checkCollisionThickness(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc5_:int = 0;
         if(!_mainBackObj)
         {
            return false;
         }
         var _loc6_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         var _loc4_:int = 0;
         _loc5_ = 1;
         while(_loc5_ <= param3 + 2)
         {
            if(_roomGrid.testGridCell(_loc6_.x,_loc6_.y + _loc5_) != 0)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_ <= param3;
      }
      
      public function checkForWall(param1:Number, param2:Number, param3:int) : Boolean
      {
         var _loc4_:int = 0;
         if(!_mainBackObj)
         {
            return false;
         }
         var _loc5_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         _loc4_ = 0;
         while(_loc4_ <= param3)
         {
            if(_roomGrid.testGridCell(_loc5_.x,_loc5_.y + _loc4_ - 1) == 0)
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      public function collisionCheckCorner(param1:Point) : Boolean
      {
         var _loc3_:int = 0;
         if(!_mainBackObj)
         {
            param1.y = 0;
            param1.x = 0;
         }
         var _loc2_:Object = _roomGrid.convertWorldPosToGrid(param1.x + _mainBackObj.x,param1.y + _mainBackObj.y);
         if(_roomGrid.testGridCell(_loc2_.x,_loc2_.y) != 0)
         {
            return false;
         }
         if(_roomGrid.testGridCell(_loc2_.x - 1,_loc2_.y) != 0 && _roomGrid.testGridCell(_loc2_.x - 1,_loc2_.y - 1) == 0 && _roomGrid.testGridCell(_loc2_.x,_loc2_.y + 1) != 0)
         {
            _loc3_ = param1.x - (_roomGrid.getRightGridPosToWorld(_loc2_.x) - _mainBackObj.x) + _roomGrid.getBottomYGridPosToWorld(_loc2_.y) - _mainBackObj.y;
            param1.y = _loc3_;
            return true;
         }
         if(_roomGrid.testGridCell(_loc2_.x + 1,_loc2_.y) != 0 && _roomGrid.testGridCell(_loc2_.x + 1,_loc2_.y - 1) == 0 && _roomGrid.testGridCell(_loc2_.x,_loc2_.y + 1) != 0)
         {
            _loc3_ = _roomGrid.getLeftGridPosToWorld(_loc2_.x) - _mainBackObj.x - param1.x + _roomGrid.getBottomYGridPosToWorld(_loc2_.y) - _mainBackObj.y;
            param1.y = _loc3_;
            return true;
         }
         return false;
      }
      
      public function checkVerticalThickness(param1:int, param2:int, param3:int) : Boolean
      {
         var _loc5_:int = 0;
         if(!_mainBackObj)
         {
            return false;
         }
         var _loc6_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         var _loc4_:int = 1;
         _loc5_ = 1;
         while(_loc5_ < param3)
         {
            if(_roomGrid.testGridCell(_loc6_.x,_loc6_.y + _loc5_) != 0)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         _loc5_ = 1;
         while(_loc5_ < param3)
         {
            if(_roomGrid.testGridCell(_loc6_.x,_loc6_.y - _loc5_) != 0)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_ >= param3;
      }
      
      public function resolveCollisionUp(param1:int, param2:int, param3:Object) : void
      {
         var _loc4_:int = 0;
         if(!_mainBackObj)
         {
            param3.gridY = -1;
         }
         var _loc5_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         _loc4_ = 1;
         while(_loc4_ <= 3)
         {
            if(_roomGrid.testGridCell(_loc5_.x,_loc5_.y - _loc4_) == 0)
            {
               param3.yPos = _roomGrid.getBottomYGridPosToWorld(_loc5_.y - _loc4_) - _mainBackObj.y;
               param3.gridY = _loc5_.y - _loc4_;
               return;
            }
            _loc4_++;
         }
         param3.gridY = -1;
      }
      
      public function getPlatforms() : Loader
      {
         return !!_platform ? _platform.loader : null;
      }
      
      override public function scrollRoom(param1:Point, param2:int, param3:Number) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         if(gMainFrame.clientInfo.roomType == 7)
         {
            _loc5_ = param1.x;
            _loc8_ = param1.y;
            _loc4_ = 0;
            _loc6_ = 0;
            _loc9_ = calcScrollAmount(_loc5_,_layerManager.bkg.scaleX,400,900,_mainBackObj.dx,param2,true);
            _loc7_ = calcScrollAmount(_loc8_ - (QuestManager.isSideScrollQuest() ? 75 : 0),_layerManager.bkg.scaleY,250,550,_mainBackObj.dy,param2,true);
            if(QuestManager.isSideScrollQuest())
            {
               if((_loc9_ < 0 ? -_loc9_ : _loc9_) > 400 || (_loc7_ < 0 ? -_loc7_ : _loc7_) > 400)
               {
                  _scrollOffset.x += _loc9_;
                  _scrollOffset.y += _loc7_;
               }
               else
               {
                  if(param3 > 0.1)
                  {
                     param3 = 0.1;
                  }
                  _scrollAcceleration.x = 60 * _loc9_ - 10 * _scrollVelocity.x;
                  _scrollAcceleration.y = 60 * _loc7_ - 10 * _scrollVelocity.y;
                  _scrollVelocity.x += _scrollAcceleration.x * param3;
                  _scrollVelocity.y += _scrollAcceleration.y * param3;
                  _loc4_ = _scrollVelocity.x * param3;
                  _loc6_ = _scrollVelocity.y * param3;
                  _scrollOffset.x += _loc4_;
                  _scrollOffset.y += _loc6_;
               }
            }
            else
            {
               _scrollOffset.x += _loc9_;
               _scrollOffset.y += _loc7_;
            }
            if(_loc9_ || _loc7_ || QuestManager.isSideScrollQuest() && (_loc4_ != 0 || _loc6_ != 0))
            {
               updateBackground();
            }
            return _loc9_ == 0 && _loc7_ == 0;
         }
         return super.scrollRoom(param1,param2,param3);
      }
   }
}

class SingletonLock
{
   public function SingletonLock()
   {
      super();
   }
}
