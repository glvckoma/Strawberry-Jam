package gui
{
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyManager;
   import buddy.BuddyXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.loader.SceneLoader;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import game.MinigameManager;
   import gui.itemWindows.ItemWindowAdventure;
   import gui.itemWindows.ItemWindowTextBar;
   import loadProgress.LoadProgress;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import room.VolumeManager;
   
   public class VolumeSelector
   {
      public static const WORLD_MAP:int = 0;
      
      public static const DANGER_MAP:int = 1;
      
      private static const MAP_X:int = -319;
      
      private static const MAP_Y:int = 0;
      
      private static const TIME_BETWEEN_REQUESTS:int = 600000;
      
      private static const AJ_EPIC_DEN_PARTY_DEF_ID:int = 36;
      
      private static const ROOMS:Array = ["lost_temple_of_zios","jamaa_township","sarepia","crystal_sands","coral_canyons","mountains_of_shivveer","appondale","crystal_reef","bahari_bay","deep_sea","pirate_ship","aussie","Balloosh"];
      
      private var _displayLayer:DisplayLayer;
      
      private var _guiLayer:DisplayObject;
      
      private var _worldMapScene:SceneLoader;
      
      private var _dangerMapScene:SceneLoader;
      
      private var _bShow:Boolean;
      
      private var _bIsLoaded:Boolean;
      
      private var _bDangerIsLoaded:Boolean;
      
      private var _volumeManager:VolumeManager;
      
      private var _debugLayer:Shape;
      
      private var _help_mc:MovieClip;
      
      private var _mcBtn:MovieClip;
      
      private var _zoneBtn:MovieClip;
      
      private var _currType:int;
      
      private var _buddyUserName:String;
      
      private var _worldMapFrame:MovieClip;
      
      private var _densAndAdventureLoadingSpiral:LoadingSpiral;
      
      private var _sortIcons:Object;
      
      private var _scrollBar:SBScrollbar;
      
      private var _epicDenWindows:WindowGenerator;
      
      private var _adventureWindows:WindowGenerator;
      
      private var _mousePos:Point;
      
      private var _bMouseDown:Boolean;
      
      private var _bCheckVolume:Boolean;
      
      private var _milliSecSinceLastListRequest:Number;
      
      private var _mapUpdateTimer:Timer;
      
      private var _worldMapload_callback:Function;
      
      private var _roomMgr:RoomManagerWorld;
      
      public function VolumeSelector()
      {
         super();
      }
      
      public function VolumeSelctor(param1:DisplayLayer) : void
      {
         _displayLayer = new DisplayLayer();
         _debugLayer = new Shape();
         _guiLayer = param1;
         param1.addChild(_displayLayer);
         _worldMapScene = new SceneLoader();
         _dangerMapScene = new SceneLoader();
         _volumeManager = new VolumeManager();
         _mousePos = new Point();
         _milliSecSinceLastListRequest = 0;
         _roomMgr = RoomManagerWorld.instance;
         _mapUpdateTimer = new Timer(15000);
         _mapUpdateTimer.addEventListener("timer",mapUpdateTimer,false,0,true);
         RoomXtCommManager.roomCountResponseCallback = handleRoomCountResponse;
         _displayLayer.addEventListener("mouseMove",onMouseMove);
         _displayLayer.addEventListener("mouseDown",onMouseDown);
         _displayLayer.addEventListener("enterFrame",onEnterFrame);
         show(false,0);
      }
      
      public function enable(param1:Boolean, param2:MovieClip = null, param3:MovieClip = null, param4:MovieClip = null) : void
      {
         if(param1)
         {
            _help_mc = param4;
            _mcBtn = param2;
            _mcBtn.addEventListener("click",onMapButtonDown,false,0,true);
            _zoneBtn = param3;
            _zoneBtn.addEventListener("click",onMapButtonDown,false,0,true);
         }
         else
         {
            _help_mc = null;
            if(_mcBtn)
            {
               _mcBtn.removeEventListener("click",onMapButtonDown);
               _mcBtn = null;
            }
            if(_zoneBtn)
            {
               _zoneBtn.removeEventListener("click",onMapButtonDown);
               _zoneBtn = null;
            }
         }
      }
      
      public function loadAssets(param1:Function) : void
      {
         _worldMapload_callback = param1;
         loadWorldMapRoom();
      }
      
      public function loadDangerAssets() : void
      {
         loadDangerMapRoom();
      }
      
      public function destroy() : void
      {
         if(_mapUpdateTimer)
         {
            _mapUpdateTimer.reset();
            _mapUpdateTimer.removeEventListener("timer",mapUpdateTimer);
            _mapUpdateTimer = null;
         }
         if(_epicDenWindows)
         {
            _epicDenWindows.destroy();
            _epicDenWindows = null;
         }
         if(_adventureWindows)
         {
            _adventureWindows.destroy();
            _adventureWindows = null;
         }
         RoomXtCommManager.roomCountResponseCallback = null;
      }
      
      public function get visible() : Boolean
      {
         return _displayLayer.visible;
      }
      
      public function show(param1:Boolean, param2:int) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         _currType = param2;
         if(param1)
         {
            SBTracker.push();
            if(param2 == 0)
            {
               setDisplayLayer(0);
               SBTracker.trackPageview("/game/play/popup/worldmap");
            }
            else if(param2 == 1)
            {
               if(!_bDangerIsLoaded)
               {
                  loadDangerMapRoom();
               }
               else
               {
                  setDisplayLayer(1);
               }
               SBTracker.trackPageview("/game/play/popup/dangermap");
            }
         }
         _bShow = param1;
         _displayLayer.visible = param1;
         if(param1)
         {
            _loc3_ = _displayLayer.parent;
            _loc3_.setChildIndex(_displayLayer,_loc3_.numChildren - 1);
            if(param2 == 0)
            {
               updateRoomCount();
               _mapUpdateTimer.start();
               setStar();
               _worldMapFrame.advWindowTab.epicDenTab.visible = false;
               _worldMapFrame.advWindowTab.advTab.visible = false;
               if(_sortIcons)
               {
                  _sortIcons.sortingPopup.visible = false;
                  _sortIcons.sortBtn.visible = true;
                  _worldMapFrame.advWindowTab.visible = true;
               }
            }
         }
         else
         {
            _volumeManager.clearHold();
            _mapUpdateTimer.reset();
            destroyDenAndAdventureWindows();
            if(_sortIcons)
            {
               _sortIcons.cinemaIcons.visible = false;
               _sortIcons.petShopIcons.visible = false;
               _sortIcons.shopIcons.visible = false;
               _sortIcons.sortingPopup.sortBtnCinema.mouse.visible = true;
               _sortIcons.sortingPopup.sortBtnCinema.down.visible = false;
               _sortIcons.sortingPopup.sortBtnCinema.btnOutHandler(null);
               _sortIcons.sortingPopup.sortBtnPetShop.mouse.visible = true;
               _sortIcons.sortingPopup.sortBtnPetShop.down.visible = false;
               _sortIcons.sortingPopup.sortBtnPetShop.btnOutHandler(null);
               _sortIcons.sortingPopup.sortBtnShop.mouse.visible = true;
               _sortIcons.sortingPopup.sortBtnShop.down.visible = false;
               _sortIcons.sortingPopup.sortBtnShop.btnOutHandler(null);
            }
         }
         if(param2 == 0 && _sortIcons && _bShow)
         {
            _sortIcons.denBtn.visible = gMainFrame.server.getCurrentRoomName().slice(3) != gMainFrame.server.userName;
         }
         _bCheckVolume = false;
         _bMouseDown = false;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(_bShow && _bCheckVolume)
         {
            _loc2_ = _volumeManager.testMouseVolumes(_mousePos,_bMouseDown,checkSortOptions);
            if(_loc2_ != null && _loc2_.message != null)
            {
               if(_loc2_.message.length > 0)
               {
                  _loc3_ = _loc2_.message.toLowerCase();
                  if(_currType == 0)
                  {
                     if(_loc3_ == "home")
                     {
                        gotoHome();
                     }
                     else if(_loc3_ != "close")
                     {
                        gotoRoom(_loc2_.message);
                     }
                     else
                     {
                        SBTracker.pop();
                     }
                     if(!GuiManager.mainHud.swapBtn.isGray || QuestManager.isInPrivateAdventureState || MinigameManager.isInReadyModeForPVP())
                     {
                        show(false,0);
                     }
                  }
                  else if(_currType == 1)
                  {
                     if(_loc3_ == "close")
                     {
                        show(false,1);
                     }
                     else
                     {
                        GenericListXtCommManager.requestGenericList(17);
                     }
                  }
               }
            }
            _bMouseDown = false;
            _bCheckVolume = false;
         }
      }
      
      private function checkSortOptions(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Array = param1.split("%");
         param1 = _loc2_[1];
         if(param1 != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               param1 = _loc2_[_loc3_];
               if(param1 != null && param1 != "")
               {
                  if(param1 == _sortIcons.cinemaIcons.name.toLowerCase() && _sortIcons.cinemaIcons.visible)
                  {
                     return false;
                  }
                  if(param1 == _sortIcons.petShopIcons.name.toLowerCase() && _sortIcons.petShopIcons.visible)
                  {
                     return false;
                  }
                  if(param1 == _sortIcons.shopIcons.name.toLowerCase() && _sortIcons.shopIcons.visible)
                  {
                     return false;
                  }
               }
               _loc3_++;
            }
         }
         return true;
      }
      
      private function gotoRoom(param1:String) : void
      {
         if(param1 == null || param1 == "")
         {
            throw new Error("ERROR: Invalid room name:" + param1);
         }
         param1 = param1.toLowerCase() + "#" + _roomMgr.shardId;
         if(param1 != gMainFrame.server.getCurrentRoomName())
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(param1);
         }
      }
      
      private function gotoHome() : void
      {
         if(gMainFrame.server.getCurrentRoomName().slice(3) == gMainFrame.server.userName)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
      }
      
      private function onMapButtonDown(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc3_:String = null;
         var _loc2_:Buddy = null;
         if(!param1.currentTarget.isGray)
         {
            if(!MinigameManager.inMinigame())
            {
               if(_worldMapScene.isValid)
               {
                  _loc4_ = gMainFrame.server.getCurrentRoomName();
                  if(param1.currentTarget == _zoneBtn && _loc4_.indexOf("den") == 0)
                  {
                     _loc3_ = _loc4_.substr(3,_loc4_.length);
                     if(_loc3_ != gMainFrame.userInfo.myUserName)
                     {
                        if(!BuddyList.listRequested)
                        {
                           _buddyUserName = _loc3_;
                           BuddyXtCommManager.sendBuddyListRequest(onBuddyListLoaded);
                           return;
                        }
                        _loc2_ = BuddyManager.getBuddyByUserName(_loc3_);
                        if(_loc2_)
                        {
                           BuddyManager.showBuddyCard({
                              "userName":_loc2_.userName,
                              "onlineStatus":_loc2_.onlineStatus
                           });
                           return;
                        }
                        AvatarXtCommManager.requestAvatarGet(_loc3_,onUserLookUpReceived,true);
                        return;
                     }
                  }
                  if(_help_mc)
                  {
                     _help_mc.visible = false;
                  }
                  show(!_bShow,0);
               }
               else if(_dangerMapScene.isValid)
               {
                  show(!_bShow,1);
               }
            }
         }
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         if(param2)
         {
            BuddyManager.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function onBuddyListLoaded() : void
      {
         var _loc1_:Buddy = null;
         if(_buddyUserName != gMainFrame.userInfo.myUserName)
         {
            _loc1_ = BuddyManager.getBuddyByUserName(_buddyUserName);
            if(_loc1_)
            {
               BuddyManager.showBuddyCard({
                  "userName":_loc1_.userName,
                  "onlineStatus":_loc1_.onlineStatus
               });
               return;
            }
            AvatarXtCommManager.requestAvatarGet(_buddyUserName,onUserLookUpReceived,true);
            return;
         }
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         _mousePos.x = param1.stageX;
         _mousePos.y = param1.stageY;
         _bCheckVolume = true;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _mousePos.x = param1.stageX;
         _mousePos.y = param1.stageY;
         _bCheckVolume = true;
         _bMouseDown = true;
      }
      
      private function loadWorldMapRoom() : void
      {
         if(!_bIsLoaded)
         {
            _bIsLoaded = true;
            LoadProgress.load(gMainFrame.clientInfo.worldMapRoom,8,onWorldMapRoomLoaded);
         }
         else if(_worldMapload_callback != null)
         {
            _worldMapload_callback();
         }
      }
      
      private function loadDangerMapRoom() : void
      {
         if(!_bDangerIsLoaded)
         {
            _bDangerIsLoaded = true;
            LoadProgress.load(gMainFrame.clientInfo.dangerMapRoom,2,onDangerMapRoomLoaded);
         }
      }
      
      private function onWorldMapRoomLoaded() : void
      {
         var _loc1_:Object = LoadProgress.entry.data;
         if(_worldMapScene == null)
         {
            throw "error loading world map";
         }
         _worldMapScene.setScene(_loc1_);
         _worldMapScene.addEventListener("complete",sceneAssetsLoaded);
      }
      
      private function onDangerMapRoomLoaded() : void
      {
         var _loc1_:Object = LoadProgress.entry.data;
         if(_dangerMapScene == null)
         {
            throw "error loading danger map";
         }
         _dangerMapScene.setScene(_loc1_);
         _dangerMapScene.addEventListener("complete",sceneAssetsLoaded);
      }
      
      private function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:SceneLoader = null;
         var _loc15_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc13_:MovieClip = null;
         LoadProgress.updateProgress(9);
         _loc12_ = SceneLoader(param1.currentTarget);
         _loc12_.removeEventListener("complete",sceneAssetsLoaded);
         var _loc14_:Array = _loc12_.getActorList("ActorLayer");
         while(_displayLayer.numChildren > 0)
         {
            _displayLayer.removeChildAt(0);
         }
         _displayLayer.x = 0;
         _displayLayer.y = 0;
         var _loc3_:Point = _loc12_.getOffset(_displayLayer);
         _loc3_.x = -319 - _loc3_.x;
         _loc3_.y = 0 - _loc3_.y;
         _displayLayer.x = _loc3_.x;
         _displayLayer.y = _loc3_.y;
         _loc7_ = 0;
         while(_loc7_ < _loc14_.length)
         {
            _loc11_ = _loc14_[_loc7_];
            _displayLayer.addChild(_loc11_.s);
            if(_loc11_.s.content)
            {
               LocalizationManager.findAllTextfields(_loc11_.s.content);
            }
            _loc7_++;
         }
         _displayLayer.addChild(_debugLayer);
         _loc3_.x = -_loc3_.x;
         _loc3_.y = -_loc3_.y;
         _volumeManager.setScene(_loc12_,_loc3_);
         zeroOutRoomCount();
         var _loc2_:Object = _loc12_.getLayer("worldMapFrame");
         if(_loc2_)
         {
            _worldMapFrame = MovieClip(_loc2_.loader.content.getChildAt(0));
            _worldMapFrame.addEventListener("mouseDown",onPullOutPopup,false,0,true);
            _worldMapFrame.addEventListener("mouseOver",onPullOutPopupOver,false,0,true);
            _worldMapFrame.addEventListener("mouseOut",onPullOutPopupOut,false,0,true);
            _worldMapFrame.advWindowTab.advTab.addEventListener("mouseDown",onAdvTab,false,0,true);
            _worldMapFrame.advWindowTab.advTab.addEventListener("mouseOver",onAdvTabOver,false,0,true);
            _worldMapFrame.advWindowTab.advTab.addEventListener("mouseOut",onTabOut,false,0,true);
            _worldMapFrame.advWindowTab.advTab.visible = false;
            _worldMapFrame.advWindowTab.downAdvTab.addEventListener("mouseDown",onAdvTab,false,0,true);
            _worldMapFrame.advWindowTab.downAdvTab.addEventListener("mouseOver",onAdvTabOver,false,0,true);
            _worldMapFrame.advWindowTab.downAdvTab.addEventListener("mouseOut",onTabOut,false,0,true);
            _worldMapFrame.advWindowTab.epicDenTab.addEventListener("mouseDown",onEpicDenTab,false,0,true);
            _worldMapFrame.advWindowTab.epicDenTab.addEventListener("mouseOver",onEpicDenTabOver,false,0,true);
            _worldMapFrame.advWindowTab.epicDenTab.addEventListener("mouseOut",onTabOut,false,0,true);
            _worldMapFrame.advWindowTab.epicDenTab.visible = false;
            _worldMapFrame.advWindowTab.downEpicDenTab.addEventListener("mouseDown",onEpicDenTab,false,0,true);
            _worldMapFrame.advWindowTab.downEpicDenTab.addEventListener("mouseOver",onEpicDenTabOver,false,0,true);
            _worldMapFrame.advWindowTab.downEpicDenTab.addEventListener("mouseOut",onTabOut,false,0,true);
            _worldMapFrame.advWindowTab.AJHQ_cont.AJHQ_btnCont.addEventListener("mouseDown",onAJHQBtn,false,0,true);
            _densAndAdventureLoadingSpiral = new LoadingSpiral(_worldMapFrame.advWindowTab.itemWindow_den,_worldMapFrame.advWindowTab.itemWindow_den.width * 0.5,_worldMapFrame.advWindowTab.itemWindow_den.height * 0.5);
            _sortIcons = _worldMapFrame.sortingIcons;
         }
         if(_sortIcons)
         {
            _sortIcons.denBtn = _sortIcons.parent.denBtn;
            _sortIcons.denBtn.addEventListener("mouseDown",onDenBtn,false,0,true);
            _sortIcons.sortBtn = _sortIcons.parent.sortBtn;
            _sortIcons.sortBtn.addEventListener("mouseDown",onSortBtn,false,0,true);
            _sortIcons.sortingPopup = _sortIcons.parent.sortingPopup;
            _sortIcons.sortingPopup.sortBtnCinema.addEventListener("mouseDown",onSortOptions,false,0,true);
            _sortIcons.sortingPopup.sortBtnPetShop.addEventListener("mouseDown",onSortOptions,false,0,true);
            _sortIcons.sortingPopup.sortBtnShop.addEventListener("mouseDown",onSortOptions,false,0,true);
            _sortIcons.sortingPopup.visible = false;
            _sortIcons.cinemaIcons.visible = false;
            _sortIcons.petShopIcons.visible = false;
            _sortIcons.shopIcons.visible = false;
            _loc15_ = _sortIcons.cinemaIcons.numChildren + _sortIcons.petShopIcons.numChildren + _sortIcons.shopIcons.numChildren;
            _loc8_ = 0;
            _loc7_ = 0;
            while(_loc7_ < _loc15_)
            {
               _loc13_ = null;
               if(_loc7_ < _sortIcons.cinemaIcons.numChildren)
               {
                  _loc13_ = MovieClip(_sortIcons.cinemaIcons.getChildAt(_loc7_));
                  _loc10_++;
               }
               else if(_loc7_ < _loc10_ + _sortIcons.petShopIcons.numChildren)
               {
                  _loc13_ = MovieClip(_sortIcons.petShopIcons.getChildAt(_loc8_));
                  _loc8_++;
               }
               else
               {
                  _loc13_ = MovieClip(_sortIcons.shopIcons.getChildAt(_loc9_));
                  _loc9_++;
               }
               if(_loc13_)
               {
                  _loc13_.addEventListener("mouseDown",onSortIcon,false,0,true);
                  _loc13_.addEventListener("mouseOver",onSortIconOver,false,0,true);
                  _loc13_.addEventListener("mouseOut",onSortIconOut,false,0,true);
               }
               _loc7_++;
            }
         }
         if(_worldMapload_callback != null)
         {
            _worldMapload_callback();
            _worldMapload_callback = null;
         }
         else
         {
            LoadProgress.show(false);
         }
      }
      
      private function setDisplayLayer(param1:int) : void
      {
         var _loc5_:Object = null;
         var _loc3_:Array = null;
         var _loc2_:Point = null;
         var _loc6_:SceneLoader = null;
         var _loc4_:int = 0;
         while(_displayLayer.numChildren > 0)
         {
            _displayLayer.removeChildAt(0);
         }
         _displayLayer.x = 0;
         _displayLayer.y = 0;
         if(param1 == 0)
         {
            _loc6_ = _worldMapScene;
         }
         else if(param1 == 1)
         {
            _loc6_ = _dangerMapScene;
         }
         _loc3_ = _loc6_.getActorList("ActorLayer");
         _loc2_ = _loc6_.getOffset(_displayLayer);
         _loc2_.x = -319 - _loc2_.x;
         _loc2_.y = 0 - _loc2_.y;
         _displayLayer.x = _loc2_.x;
         _displayLayer.y = _loc2_.y;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            _displayLayer.addChild(_loc5_.s);
            if(_loc5_.s.content)
            {
               LocalizationManager.findAllTextfields(_loc5_.s.content);
            }
            _loc4_++;
         }
         _loc2_.x = -_loc2_.x;
         _loc2_.y = -_loc2_.y;
         _volumeManager.setScene(_loc6_,_loc2_);
      }
      
      private function createDenWindows(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(_scrollBar)
         {
            _scrollBar.destroy();
            _scrollBar = null;
         }
         if(_epicDenWindows)
         {
            _epicDenWindows.destroy();
            _epicDenWindows = null;
         }
         if(param1)
         {
            _loc2_ = Math.min(param1.length,20);
            _epicDenWindows = new WindowGenerator();
            _epicDenWindows.init(1,_loc2_,_loc2_,0,3,0,ItemWindowTextBar,param1,"",{"mouseDown":winMouseDown},null,null,false,false);
            _densAndAdventureLoadingSpiral.visible = false;
            while(_worldMapFrame.advWindowTab.itemWindow_den.numChildren > 2)
            {
               _worldMapFrame.advWindowTab.itemWindow_den.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_den.numChildren - 1);
            }
            _worldMapFrame.advWindowTab.itemWindow_den.addChild(_epicDenWindows);
            _scrollBar = new SBScrollbar();
            _scrollBar.init(_epicDenWindows,267,335,3,"scrollbar2",36);
         }
      }
      
      private function createAdventureWindows() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(_adventureWindows)
         {
            while(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren > 2)
            {
               _worldMapFrame.advWindowTab.itemWindow_adv.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren - 1);
            }
            _worldMapFrame.advWindowTab.itemWindow_adv.addChild(_adventureWindows);
            if(_scrollBar)
            {
               _scrollBar.destroy();
            }
            _scrollBar = new SBScrollbar();
            _scrollBar.init(_adventureWindows,267,390,3,"scrollbar2",54);
         }
         else
         {
            _densAndAdventureLoadingSpiral.setNewParent(_worldMapFrame.advWindowTab.itemWindow_adv,_worldMapFrame.advWindowTab.itemWindow_adv.width * 0.5,_worldMapFrame.advWindowTab.itemWindow_adv.height * 0.5);
            _densAndAdventureLoadingSpiral.visible = true;
            _loc1_ = QuestManager.getAvailableScriptDefs(createAdventureWindows);
            if(_loc1_ != null)
            {
               if(_scrollBar)
               {
                  _scrollBar.destroy();
                  _scrollBar = null;
               }
               if(_adventureWindows)
               {
                  _adventureWindows.destroy();
                  _adventureWindows = null;
               }
               _loc2_ = Math.min(_loc1_.length,20);
               _adventureWindows = new WindowGenerator();
               _adventureWindows.init(1,_loc2_,_loc2_,0,3,0,ItemWindowAdventure,null,"",{"mouseDown":adventureMouseDown},{"scriptIds":_loc1_},onAdventureWindowsLoaded,false,false);
            }
         }
      }
      
      private function onAdventureWindowsLoaded() : void
      {
         _densAndAdventureLoadingSpiral.visible = false;
         while(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren > 2)
         {
            _worldMapFrame.advWindowTab.itemWindow_adv.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren - 1);
         }
         _worldMapFrame.advWindowTab.itemWindow_adv.addChild(_adventureWindows);
         _scrollBar = new SBScrollbar();
         _scrollBar.init(_adventureWindows,267,393,3,"scrollbar2",55.5);
      }
      
      private function destroyDenAndAdventureWindows() : void
      {
         if(_scrollBar)
         {
            _scrollBar.destroy();
            _scrollBar = null;
         }
         if(_epicDenWindows)
         {
            _epicDenWindows.destroy();
            _epicDenWindows = null;
         }
         if(_adventureWindows)
         {
            _adventureWindows.destroy();
            _adventureWindows = null;
         }
         if(_worldMapFrame)
         {
            while(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren > 2)
            {
               _worldMapFrame.advWindowTab.itemWindow_adv.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_adv.numChildren - 1);
            }
            while(_worldMapFrame.advWindowTab.itemWindow_den.numChildren > 2)
            {
               _worldMapFrame.advWindowTab.itemWindow_den.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_den.numChildren - 1);
            }
            _worldMapFrame.advWindowTab.gotoAndStop("off");
         }
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.server.getCurrentRoomName(false) != "den" + param1.currentTarget.txt.text)
         {
            DenXtCommManager.requestDenJoinFull("den" + param1.currentTarget.txt.text);
         }
         show(false,0);
      }
      
      private function adventureMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = param1.currentTarget.performContinueChecks();
         if(_loc2_ != null)
         {
            _worldMapFrame.advWindowTab.gotoAndPlay("close");
            destroyDenAndAdventureWindows();
            _loc2_.func(_loc2_.defId);
            _loc2_ = null;
            _bShow = true;
         }
      }
      
      private function onEpicDenTab(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         _worldMapFrame.advWindowTab.AJHQ_cont.visible = true;
         _worldMapFrame.advWindowTab.itemWindow_adv.visible = false;
         _worldMapFrame.advWindowTab.itemWindow_den.visible = true;
         if(_worldMapFrame.advWindowTab.hasSetHQText == null)
         {
            _loc2_ = PartyManager.getPartyDef(36);
            if(_loc2_)
            {
               LocalizationManager.translateId(_worldMapFrame.advWindowTab.AJHQ_cont.AJHQ_btnCont.mouse.mouse.txt,_loc2_.titleStrId);
               LocalizationManager.translateId(_worldMapFrame.advWindowTab.AJHQ_cont.AJHQ_btnCont.mouse.up.txt,_loc2_.titleStrId);
               LocalizationManager.translateId(_worldMapFrame.advWindowTab.AJHQ_cont.AJHQ_btnCont.down.txt,_loc2_.titleStrId);
               _worldMapFrame.advWindowTab.hasSetHQText = true;
            }
         }
         if(_worldMapFrame.advWindowTab.currentFrameLabel == "off")
         {
            _worldMapFrame.advWindowTab.gotoAndPlay("open");
            _worldMapFrame.advWindowTab.epicDenTab.visible = true;
            LocalizationManager.translateId(_worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,8700);
            checkAndLoadEpicDenWindows();
         }
         else if(_worldMapFrame.advWindowTab.currentFrameLabel == "on")
         {
            if(_worldMapFrame.advWindowTab.advTab.visible)
            {
               _worldMapFrame.advWindowTab.advTab.visible = false;
               _worldMapFrame.advWindowTab.epicDenTab.visible = true;
               LocalizationManager.translateId(_worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,8700);
               checkAndLoadEpicDenWindows();
            }
            else
            {
               _worldMapFrame.advWindowTab.gotoAndPlay("close");
               _worldMapFrame.advWindowTab.epicDenTab.visible = false;
            }
         }
      }
      
      private function onEpicDenTabOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15072),param1.currentTarget.width * 0.5 + param1.currentTarget.parent.x + param1.currentTarget.x,param1.currentTarget.parent.y + param1.currentTarget.y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function checkAndLoadEpicDenWindows() : void
      {
         var _loc1_:Number = Number(new Date().getTime());
         if(_loc1_ - _milliSecSinceLastListRequest > 600000 || _epicDenWindows == null)
         {
            _densAndAdventureLoadingSpiral.setNewParent(_worldMapFrame.advWindowTab.itemWindow_den,_worldMapFrame.advWindowTab.itemWindow_den.width * 0.5,_worldMapFrame.advWindowTab.itemWindow_den.height * 0.5);
            _densAndAdventureLoadingSpiral.visible = true;
            _milliSecSinceLastListRequest = _loc1_;
            DenXtCommManager.denHighestCallback = createDenWindows;
            DenXtCommManager.requestDenHighest();
         }
         else
         {
            while(_worldMapFrame.advWindowTab.itemWindow_den.numChildren > 2)
            {
               _worldMapFrame.advWindowTab.itemWindow_den.removeChildAt(_worldMapFrame.advWindowTab.itemWindow_den.numChildren - 1);
            }
            _worldMapFrame.advWindowTab.itemWindow_den.addChild(_epicDenWindows);
            if(_scrollBar)
            {
               _scrollBar.destroy();
            }
            _scrollBar = new SBScrollbar();
            _scrollBar.init(_epicDenWindows,267,335,3,"scrollbar2",36);
         }
      }
      
      private function onPullOutPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPullOutPopupOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _volumeManager.clearHold(false);
         _bShow = false;
      }
      
      private function onPullOutPopupOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _bShow = true;
      }
      
      private function onAdvTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            _worldMapFrame.advWindowTab.AJHQ_cont.visible = false;
            _worldMapFrame.advWindowTab.itemWindow_adv.visible = true;
            _worldMapFrame.advWindowTab.itemWindow_den.visible = false;
            if(_worldMapFrame.advWindowTab.currentFrameLabel == "off")
            {
               _worldMapFrame.advWindowTab.gotoAndPlay("open");
               _worldMapFrame.advWindowTab.advTab.visible = true;
               LocalizationManager.translateId(_worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,9797);
               createAdventureWindows();
            }
            else if(_worldMapFrame.advWindowTab.currentFrameLabel == "on")
            {
               if(_worldMapFrame.advWindowTab.epicDenTab.visible)
               {
                  _worldMapFrame.advWindowTab.advTab.visible = true;
                  _worldMapFrame.advWindowTab.epicDenTab.visible = false;
                  LocalizationManager.translateId(_worldMapFrame.advWindowTab.titleBanner.windowTitleTxt,9797);
                  createAdventureWindows();
               }
               else
               {
                  _worldMapFrame.advWindowTab.gotoAndPlay("close");
                  _worldMapFrame.advWindowTab.advTab.visible = false;
               }
            }
         }
      }
      
      private function onAdvTabOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(MovieClip(param1.currentTarget.parent.parent),LocalizationManager.translateIdOnly(15036),param1.currentTarget.width * 0.5 + param1.currentTarget.parent.x + param1.currentTarget.x,param1.currentTarget.parent.y + param1.currentTarget.y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onTabOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSortOptions(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == "sortBtnShop")
         {
            _sortIcons.cinemaIcons.visible = false;
            _sortIcons.petShopIcons.visible = false;
            _sortIcons.shopIcons.visible = !_sortIcons.shopIcons.visible;
            if(_sortIcons.shopIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            _sortIcons.sortingPopup.sortBtnCinema.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnCinema.down.visible = false;
            _sortIcons.sortingPopup.sortBtnCinema.btnOutHandler(null);
            _sortIcons.sortingPopup.sortBtnPetShop.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnPetShop.down.visible = false;
            _sortIcons.sortingPopup.sortBtnPetShop.btnOutHandler(null);
         }
         else if(param1.currentTarget.name == "sortBtnCinema")
         {
            _sortIcons.cinemaIcons.visible = !_sortIcons.cinemaIcons.visible;
            _sortIcons.petShopIcons.visible = false;
            _sortIcons.shopIcons.visible = false;
            if(_sortIcons.cinemaIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            _sortIcons.sortingPopup.sortBtnPetShop.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnPetShop.down.visible = false;
            _sortIcons.sortingPopup.sortBtnPetShop.btnOutHandler(null);
            _sortIcons.sortingPopup.sortBtnShop.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnShop.down.visible = false;
            _sortIcons.sortingPopup.sortBtnShop.btnOutHandler(null);
         }
         else
         {
            _sortIcons.cinemaIcons.visible = false;
            _sortIcons.petShopIcons.visible = !_sortIcons.petShopIcons.visible;
            _sortIcons.shopIcons.visible = false;
            if(_sortIcons.petShopIcons.visible)
            {
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            else
            {
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            _sortIcons.sortingPopup.sortBtnCinema.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnCinema.down.visible = false;
            _sortIcons.sortingPopup.sortBtnCinema.btnOutHandler(null);
            _sortIcons.sortingPopup.sortBtnShop.mouse.visible = true;
            _sortIcons.sortingPopup.sortBtnShop.down.visible = false;
            _sortIcons.sortingPopup.sortBtnShop.btnOutHandler(null);
         }
      }
      
      private function onSortIcon(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc3_:String = param1.currentTarget.name.replace("___",".");
         var _loc2_:Array = _loc3_.split("___");
         if(_loc3_ != gMainFrame.server.getCurrentRoomName())
         {
            if(_loc2_.length == 2)
            {
               RoomManagerWorld.instance.setGotoSpawnPoint(_loc2_[1].toLowerCase());
            }
            gotoRoom(_loc2_[0]);
         }
      }
      
      private function onSortIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _volumeManager.clearHold(false);
         _bShow = false;
      }
      
      private function onSortIconOut(param1:MouseEvent) : void
      {
         if(visible)
         {
            _bShow = true;
         }
      }
      
      private function onDenBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gotoHome();
      }
      
      private function onSortBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_sortIcons)
         {
            _sortIcons.sortingPopup.visible = !_sortIcons.sortingPopup.visible;
         }
      }
      
      private function onAJHQBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         PartyXtCommManager.sendJoinPartyRequest(36);
      }
      
      private function mapUpdateTimer(param1:TimerEvent) : void
      {
         updateRoomCount();
      }
      
      private function updateRoomCount() : void
      {
         zeroOutRoomCount();
         if(BuddyManager.hasOnlineBuddies())
         {
            RoomXtCommManager.sendRoomCountRequest();
         }
      }
      
      private function handleRoomCountResponse(param1:Object) : void
      {
         var _loc8_:String = null;
         var _loc4_:Array = null;
         var _loc9_:Object = null;
         var _loc6_:int = 2;
         var _loc2_:int = int(param1[_loc6_++]);
         var _loc7_:int = _loc6_ + _loc2_ * 2;
         var _loc3_:Dictionary = new Dictionary(true);
         while(_loc6_ < _loc7_)
         {
            _loc8_ = param1[_loc6_++];
            _loc4_ = _loc8_.split(".");
            if(_loc4_[0] == "oceans")
            {
               _loc8_ = _loc4_[1].slice(0,_loc4_[1].indexOf("#"));
            }
            else
            {
               _loc8_ = _loc4_[0];
            }
            _loc3_[_loc8_] = param1[_loc6_++];
         }
         for(var _loc5_ in _loc3_)
         {
            _loc9_ = _worldMapScene.getLayer(_loc5_);
            if(_loc9_)
            {
               _loc9_.loader.content.buddy.buddyText.text = _loc3_[_loc5_];
            }
         }
      }
      
      private function zeroOutRoomCount() : void
      {
         var _loc1_:Object = null;
         if(_worldMapScene && _worldMapScene.isValid)
         {
            for each(var _loc2_ in ROOMS)
            {
               _loc1_ = _worldMapScene.getLayer(_loc2_);
               if(_loc1_ && _loc1_.loader && _loc1_.loader.content)
               {
                  _loc1_.loader.content.buddy.buddyText.text = 0;
               }
            }
         }
      }
      
      private function setStar() : void
      {
         var _loc1_:Object = null;
         for each(var _loc2_ in ROOMS)
         {
            _loc1_ = _worldMapScene.getLayer(_loc2_);
            if(_loc1_ && _loc1_.loader && _loc1_.loader.content)
            {
               _loc1_.loader.content.star.visible = false;
            }
         }
         _loc1_ = _worldMapScene.getLayer(gMainFrame.userInfo.worldMapRoomName);
         if(_loc1_ && _loc1_.loader && _loc1_.loader.content)
         {
            _loc1_.loader.content.star.visible = true;
         }
      }
   }
}

