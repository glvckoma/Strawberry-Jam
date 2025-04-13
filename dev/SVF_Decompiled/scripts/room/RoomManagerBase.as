package room
{
   import Enums.DenItemDef;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.SceneLoader;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   import ru.etcs.utils.getDefinitionNames;
   
   public class RoomManagerBase
   {
      protected static const ENABLE_DEBUG_DRAW:Boolean = false;
      
      protected var _scrollOffset:Point;
      
      protected var _scene:SceneLoader;
      
      protected var _layers:Array;
      
      protected var _portals:Array;
      
      protected var _spawns:Array;
      
      protected var _lines:Array;
      
      protected var _actionPoints:Array;
      
      protected var _roomSettings:Object;
      
      protected var _volumes:Array;
      
      protected var _paths:Array;
      
      protected var _stageMin:Point;
      
      protected var _stageMax:Point;
      
      protected var _grid:Object;
      
      protected var _roomGrid:RoomGrid;
      
      protected var _mainBackObj:Object;
      
      protected var _roomMusic:SBMusic;
      
      protected var _gaRoomName:String;
      
      protected var _sfxMediaHelpers:Array;
      
      protected var _parentIndices:Dictionary;
      
      protected var _assetsLoaded:Boolean;
      
      protected var _persistentObject:Object;
      
      protected var _volumeManager:VolumeManager;
      
      protected var _layerManager:LayerManager;
      
      protected var _assetPool:Dictionary;
      
      protected var _objectSwapper:Object;
      
      protected var _checkSurroundingAssets:Boolean;
      
      private var _numTimesForceChangedBgPos:int;
      
      private var _buckets:Array;
      
      private var _isDenPreview:Boolean;
      
      private var _customMusicDef:int;
      
      private var _gridCellDiameter:int;
      
      public function RoomManagerBase()
      {
         super();
      }
      
      public function get volumeManager() : VolumeManager
      {
         return _volumeManager;
      }
      
      public function get layerManager() : LayerManager
      {
         return _layerManager;
      }
      
      public function get scrollOffset() : Point
      {
         return _scrollOffset;
      }
      
      public function init(param1:LayerManager) : void
      {
         _layerManager = param1;
         _scene = new SceneLoader(onSceneLoadComplete);
         _volumeManager = new VolumeManager();
         _roomGrid = new RoomGrid();
         _scrollOffset = new Point(0,0);
         _stageMin = new Point(0,0);
         _stageMax = new Point(0,0);
         _sfxMediaHelpers = [];
         _objectSwapper = {};
         gMainFrame.stage.addEventListener("RoomEventLoadSfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySwfSfx",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventPlaySwfSfxByClass",onRoomEvent,false,0,true);
         gMainFrame.stage.addEventListener("RoomEventAttachEmote",onRoomEvent,false,0,true);
      }
      
      public function destroy() : void
      {
         gMainFrame.stage.removeEventListener("RoomEventLoadSfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySwfSfx",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventPlaySwfSfxByClass",onRoomEvent);
         gMainFrame.stage.removeEventListener("RoomEventAttachEmote",onRoomEvent);
      }
      
      public function exitRoom(param1:Boolean = false) : void
      {
         _layerManager.bkg.visible = false;
         _numTimesForceChangedBgPos = 0;
         _persistentObject = null;
         if(_roomMusic && !param1)
         {
            _roomMusic.stop();
         }
         if(_mainBackObj && !param1)
         {
            _assetsLoaded = false;
            _scrollOffset.x = 0;
            _scrollOffset.y = 0;
            updateBackground(true);
            while(_layerManager.room_bkg.numChildren)
            {
               _layerManager.room_bkg.removeChildAt(0);
            }
            while(_layerManager.room_fg.numChildren)
            {
               _layerManager.room_fg.removeChildAt(0);
            }
            while(_layerManager.room_super_fg.numChildren)
            {
               _layerManager.room_super_fg.removeChildAt(0);
            }
            while(_layerManager.room_bkg_main.numChildren)
            {
               _layerManager.room_bkg_main.removeChildAt(0);
            }
            while(_layerManager.room_avatars.numChildren)
            {
               _layerManager.room_avatars.removeChildAt(0);
            }
            while(_layerManager.flying_avatars.numChildren)
            {
               _layerManager.flying_avatars.removeChildAt(0);
            }
            while(_layerManager.preview_room_avatar.numChildren)
            {
               _layerManager.preview_room_avatar.removeChildAt(0);
            }
            while(_layerManager.preview_room_flying_avatar.numChildren)
            {
               _layerManager.preview_room_flying_avatar.removeChildAt(0);
            }
            while(_layerManager.room_chat.numChildren)
            {
               _layerManager.room_chat.removeChildAt(0);
            }
            while(_layerManager.room_orbs.numChildren)
            {
               _layerManager.room_orbs.removeChildAt(0);
            }
            if(_buckets)
            {
               _buckets = null;
            }
            _layerManager.room_avatars.release();
            _mainBackObj = null;
            _layers = null;
            _volumeManager.release();
            _grid = null;
            _portals = null;
            _spawns = null;
            _lines = null;
            _volumes = null;
            _paths = null;
            _actionPoints = null;
            _scene.release();
         }
      }
      
      protected function loadRoom_base(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:* = param1;
         exitRoom(param3);
         if(gMainFrame.clientInfo.extCallsActive)
         {
            ExternalInterface.call("mrc",["sr",gMainFrame.server.getCurrentRoomName()]);
            DebugUtility.debugTrace("mrc:sr command sent - roomname:" + gMainFrame.server.getCurrentRoomName() + " fullName:" + _loc4_);
         }
         _loc4_ = _loc4_.replace(/\./g,"/");
         var _loc5_:int = int(_loc4_.indexOf("#"));
         if(_loc5_ >= 0)
         {
            _loc4_ = _loc4_.substring(0,_loc5_);
         }
         _loc4_ += ".xroom";
         _gaRoomName = "/game/play/room/#" + _loc4_;
         LoadProgress.load("roomDefs/" + _loc4_.toLowerCase(),10,param2);
      }
      
      protected function resetCurrentRoom_base(param1:String) : void
      {
         var _loc2_:* = param1;
         _loc2_ = _loc2_.replace(/\./g,"/");
         var _loc3_:int = int(_loc2_.indexOf("#"));
         if(_loc3_ >= 0)
         {
            _loc2_ = _loc2_.substring(0,_loc3_);
         }
         _loc2_ += ".xroom";
         _isDenPreview = false;
      }
      
      protected function onRoomLoaded_base(param1:Function, param2:Object, param3:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc9_:Object = null;
         var _loc7_:DenItemDef = null;
         var _loc4_:Number = NaN;
         _layerManager.bkg.visible = false;
         _layerManager.bkg.x = 0;
         _layerManager.bkg.y = 0;
         _isDenPreview = param3;
         var _loc10_:Object = param2 != null ? param2 : LoadProgress.entry.data;
         if(_loc10_ == null)
         {
            throw "error loading room:" + _gaRoomName;
         }
         _scene.setScene(_loc10_);
         _scene.addEventListener("complete",param1);
         _roomSettings = _scene.getActorList("ActorSettings")[0];
         _stageMin.x = _roomSettings.xmin;
         _stageMin.y = _roomSettings.ymin;
         _stageMax.x = _roomSettings.xmax;
         _stageMax.y = _roomSettings.ymax;
         var _loc8_:Number = Math.ceil(Math.max(900 / (_stageMax.x - _stageMin.x + 900),550 / (_stageMax.y - _stageMin.y + 550)) * 100) / 100;
         _loc8_ += _loc8_ * 0.1;
         if(_loc8_ > 1)
         {
            _loc8_ = 1;
         }
         if(_loc8_ > _layerManager.bkg.scaleX)
         {
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _loc8_;
         }
         _grid = _roomSettings.grid;
         _roomGrid.setGrid(_grid);
         _gridCellDiameter = _roomGrid.getCellDiameter();
         if(customMusicDef != 0)
         {
            _loc7_ = DenXtCommManager.getDenItemDef(customMusicDef);
            if(_loc7_)
            {
               playMusicTrack(_loc7_.abbrName + ".mp3",_loc7_.flag / 100);
            }
         }
         else if(_roomSettings.hasOwnProperty("music") && _gaRoomName.indexOf("player_den") == -1)
         {
            if(_roomSettings.hasOwnProperty("musicVol") && _roomSettings.musicVol >= 0 && _roomSettings.musicVol <= 100)
            {
               _loc4_ = _roomSettings.musicVol / 100;
            }
            else
            {
               _loc4_ = 0.5;
            }
            playMusicTrack(_roomSettings.music,_loc4_);
         }
         _layers = _scene.getActorList("ActorLayer");
         _loc6_ = 0;
         while(_loc6_ < _layers.length)
         {
            _loc9_ = _layers[_loc6_];
            if(_loc9_.layer == 0)
            {
               _layerManager.room_avatars.x = _loc9_.x;
               _layerManager.room_avatars.y = _loc9_.y;
               _layerManager.flying_avatars.x = _loc9_.x;
               _layerManager.flying_avatars.y = _loc9_.y;
               _layerManager.room_bkg_main.x = _loc9_.x;
               _layerManager.room_bkg_main.y = _loc9_.y;
               _layerManager.room_chat.x = _loc9_.x;
               _layerManager.room_chat.y = _loc9_.y;
               _layerManager.room_orbs.x = _loc9_.x;
               _layerManager.room_orbs.y = _loc9_.y;
               if(param3)
               {
                  _layerManager.preview_room_avatar.x = _loc9_.x;
                  _layerManager.preview_room_avatar.y = _loc9_.y;
                  _layerManager.preview_room_flying_avatar.x = _loc9_.x;
                  _layerManager.preview_room_flying_avatar.y = _loc9_.y;
               }
               _mainBackObj = _loc9_;
               break;
            }
            _loc6_++;
         }
         _portals = _scene.getActorList("ActorPortal");
         _spawns = _scene.getActorList("ActorSpawn");
         _lines = _scene.getActorList("ActorCollisionPoint");
         _volumes = _scene.getActorList("ActorVolume");
         _actionPoints = _scene.getActorList("ActorAction");
         _paths = _scene.getActorList("ActorPath");
         _scrollOffset.x = -_stageMin.x;
         _scrollOffset.y = -_stageMin.y;
         if(!param3)
         {
            SBTracker.flush();
            SBTracker.trackPageview(_gaRoomName);
         }
      }
      
      protected function roomLoadComplete() : void
      {
         LoadProgress.show(false);
      }
      
      protected function sceneAssetsLoaded(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:Point = null;
         var _loc12_:Object = null;
         var _loc5_:Object = null;
         var _loc11_:Object = null;
         var _loc6_:Rectangle = null;
         _scene.removeEventListener("complete",sceneAssetsLoaded);
         _assetPool = new Dictionary();
         _parentIndices = new Dictionary();
         if(!_layers)
         {
            return;
         }
         var _loc10_:int = _layerManager.room_bkg.numChildren;
         var _loc2_:int = _layerManager.room_fg.numChildren;
         var _loc3_:int = _layerManager.room_super_fg.numChildren;
         var _loc9_:int = int(_layers.length);
         _loc7_ = 0;
         while(_loc7_ < _loc9_)
         {
            _loc12_ = _layers[_loc7_];
            _loc12_.s.mouseEnabled = false;
            _loc12_.s.mouseChildren = false;
            _loc5_ = _isDenPreview ? _layerManager.preview_room_avatar : _layerManager.room_avatars;
            switch(_loc12_.layer)
            {
               case 0:
                  _loc12_.pIndex = _loc10_++;
                  _parentIndices[_loc12_.s] = _loc12_.pIndex;
                  _layerManager.room_bkg.addChild(_loc12_.s);
                  break;
               case 1:
                  _loc5_.addChild(_loc12_.s);
                  break;
               case 2:
                  _loc12_.pIndex = _loc2_++;
                  _parentIndices[_loc12_.s] = _loc12_.pIndex;
                  _layerManager.room_fg.addChild(_loc12_.s);
                  break;
               case 4:
                  _loc12_.pIndex = _loc3_++;
                  _parentIndices[_loc12_.s] = _loc12_.pIndex;
                  _layerManager.room_super_fg.addChild(_loc12_.s);
            }
            if(_loc12_.hasOwnProperty("sortHeight"))
            {
               _loc12_.s.name = _loc12_.sortHeight;
            }
            if(_loc12_.layer)
            {
               _loc4_ = new Point(_loc12_.x,_loc12_.y);
               convertToWorldSpace(_loc4_);
               setLayerMatrix(_loc12_.s,_loc12_.flip,_loc12_.scaleX,_loc12_.scaleY,_loc12_.width,_loc12_.height,_loc4_.x,_loc4_.y);
            }
            if(_loc12_.typeIndex == 1 || _loc12_.typeIndex == 2 || _loc12_.dx != 1 || _loc12_.dy != 1)
            {
               _loc12_.excludeFromCull = 1;
            }
            _loc7_++;
         }
         if(_portals)
         {
            _loc7_ = 0;
            while(_loc7_ < _portals.length)
            {
               _loc12_ = _portals[_loc7_];
               if(_loc12_.type == 1)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _layers.length)
                  {
                     _loc11_ = _layers[_loc8_];
                     if(_loc11_.name == _loc12_["goto"])
                     {
                        _loc11_.s.parent.removeChild(_loc11_.s);
                        _loc11_.excludeFromCull = 1;
                        break;
                     }
                     _loc8_++;
                  }
               }
               _loc7_++;
            }
         }
         if(!_scene._useDynamicLoading)
         {
            _loc7_ = 0;
            while(_loc7_ < _layers.length)
            {
               _loc12_ = _layers[_loc7_];
               _loc6_ = _loc12_.s.getBounds(_loc12_.s.parent);
               _loc12_.offsetX = _loc6_.left - _loc12_.s.x;
               _loc12_.offsetY = _loc6_.top - _loc12_.s.y;
               _loc7_++;
            }
         }
         _assetsLoaded = true;
         _checkSurroundingAssets = true;
         updateBackground();
         setupBuckets();
         _volumeManager.setScene(_scene,new Point(_mainBackObj.x,_mainBackObj.y));
         _layerManager.bkg.visible = true;
         if(!_isDenPreview)
         {
            _layerManager.showAvatarsAndRelatedItems(true);
         }
         else
         {
            _layerManager.showAvatarsAndRelatedItems(false);
         }
      }
      
      protected function onSceneLoadComplete() : void
      {
         LoadProgress.show(false);
      }
      
      protected function setupBuckets() : void
      {
         var _loc8_:int = 0;
         var _loc14_:Object = null;
         var _loc18_:Sprite = null;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         var _loc19_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc12_:int = 0;
         var _loc5_:int = 0;
         var _loc16_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc20_:Object = null;
         var _loc21_:Number = 1.7976931348623157e+308;
         var _loc1_:Number = Number.MIN_VALUE;
         var _loc13_:Number = 1.7976931348623157e+308;
         var _loc2_:Number = Number.MIN_VALUE;
         if(_scene._useDynamicLoading && _layers.length > 1000)
         {
            _loc8_ = 0;
            while(_loc8_ < _layers.length)
            {
               _loc14_ = _layers[_loc8_];
               _loc15_ = 0;
               _loc17_ = 0;
               if(_loc14_.layer == 1)
               {
                  _loc18_ = _isDenPreview ? _layerManager.preview_room_avatar : _layerManager.room_avatars;
                  _loc15_ = _loc18_.parent.x;
                  _loc17_ = _loc18_.parent.y;
               }
               else
               {
                  _loc18_ = _layerManager.room_bkg;
               }
               _loc15_ += _loc14_.offsetX;
               _loc17_ += _loc14_.offsetY;
               _loc9_ = _layerManager.bkg.scaleX;
               _loc10_ = (_loc14_.s.x + _loc18_.x + _loc15_) * _loc9_;
               _loc19_ = (_loc14_.s.x + _loc14_.width + _loc18_.x + _loc15_) * _loc9_;
               _loc11_ = (_loc14_.s.y + _loc18_.y + _loc17_) * _loc9_;
               _loc3_ = (_loc14_.s.y + _loc14_.height + _loc18_.y + _loc17_) * _loc9_;
               _loc14_.bLeft = _loc10_;
               _loc14_.bRight = _loc19_;
               _loc14_.bTop = _loc11_;
               _loc14_.bBottom = _loc3_;
               if(_loc10_ < _loc21_)
               {
                  _loc21_ = _loc10_;
               }
               if(_loc19_ > _loc1_)
               {
                  _loc1_ = _loc19_;
               }
               if(_loc11_ < _loc13_)
               {
                  _loc13_ = _loc11_;
               }
               if(_loc3_ > _loc2_)
               {
                  _loc2_ = _loc3_;
               }
               _loc8_++;
            }
            _loc4_ = Math.ceil((_loc1_ - _loc21_) / 2700);
            _loc12_ = Math.ceil((_loc2_ - _loc13_) / 2700);
            _loc5_ = (_loc1_ - _loc21_) / _loc4_;
            _loc16_ = (_loc2_ - _loc13_) / _loc12_;
            _buckets = [];
            _loc6_ = 0;
            while(_loc6_ < _loc12_)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc4_)
               {
                  _buckets[_loc4_ * _loc6_ + _loc7_] = {
                     "x":_loc21_ + _loc5_ * _loc7_,
                     "y":_loc13_ + _loc16_ * _loc6_,
                     "width":_loc5_,
                     "height":_loc16_,
                     "scrollOffsetX":_scrollOffset.x,
                     "scrollOffsetY":_scrollOffset.y
                  };
                  _loc7_++;
               }
               _loc6_++;
            }
            _loc8_ = 0;
            while(_loc8_ < _layers.length)
            {
               _loc14_ = _layers[_loc8_];
               _loc7_ = Math.floor(((_loc14_.bRight + _loc14_.bLeft) * 0.5 - _loc21_) / _loc5_);
               _loc6_ = Math.floor(((_loc14_.bBottom + _loc14_.bTop) * 0.5 - _loc13_) / _loc16_);
               _loc14_.bucketIndex = _loc4_ * _loc6_ + _loc7_;
               _loc20_ = _buckets[_loc14_.bucketIndex];
               if(_loc14_.bRight > _loc20_.x + _loc20_.width)
               {
                  _loc20_.width = _loc14_.bRight - _loc20_.x;
               }
               if(_loc14_.bLeft < _loc20_.x)
               {
                  _loc20_.width += _loc20_.x - _loc14_.bLeft;
                  _loc20_.x = _loc14_.bLeft;
               }
               if(_loc14_.bBottom > _loc20_.y + _loc20_.height)
               {
                  _loc20_.height = _loc14_.bBottom - _loc20_.y;
               }
               if(_loc14_.bTop < _loc20_.y)
               {
                  _loc20_.height += _loc20_.y - _loc14_.bTop;
                  _loc20_.y = _loc14_.bTop;
               }
               if(_loc14_.bucketIndex < 0 || _loc14_.bucketIndex >= _buckets.length)
               {
                  throw new Error("Bucket index out of range!");
               }
               _loc8_++;
            }
         }
      }
      
      public function findSpawn(param1:Array, param2:String) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(param1 == null)
         {
            param1 = _spawns;
         }
         if(param1 != null)
         {
            while(_loc3_ < param1.length)
            {
               if(param1[_loc3_].name == param2)
               {
                  _loc4_ = param1[_loc3_];
                  break;
               }
               _loc3_++;
            }
         }
         return _loc4_;
      }
      
      public function findLayers(param1:String) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         if(_layers != null)
         {
            while(_loc3_ < _layers.length)
            {
               if(_layers[_loc3_].name == param1)
               {
                  if(_loc2_ == null)
                  {
                     _loc2_ = [];
                  }
                  _loc2_.push(_layers[_loc3_]);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      protected function playMusicTrack(param1:String, param2:Number) : void
      {
         if(param1 == null || param1 == "")
         {
            return;
         }
         if(!_roomMusic)
         {
            if(_persistentObject)
            {
               _persistentObject.muteChanged(true);
            }
            _roomMusic = new SBMusic(param1,true,param2);
         }
         else
         {
            _roomMusic.stop();
            _roomMusic.playNewMusic(param1,true,param2);
         }
         if(_roomMusic && SBAudio.isMusicMuted)
         {
            _roomMusic.toggleMute();
         }
      }
      
      protected function playPreviousMusicTrack() : void
      {
         if(_roomMusic)
         {
            _roomMusic.stop();
            if(_roomMusic.previouslyPlayedFilename == null || _roomMusic.previouslyPlayedFilename == "")
            {
               if(_persistentObject)
               {
                  _roomMusic = null;
                  _persistentObject.muteChanged(SBAudio.isMusicMuted);
               }
               return;
            }
            _roomMusic.playNewMusic(_roomMusic.previouslyPlayedFilename,true,_roomMusic.previousVolume);
            if(SBAudio.isMusicMuted)
            {
               _roomMusic.toggleMute();
            }
         }
      }
      
      protected function tryToPlayOriginalTrack(param1:String, param2:Number) : void
      {
         if(_roomMusic)
         {
            _roomMusic.stop();
            if(param1 == null || param1 == "")
            {
               if(_persistentObject)
               {
                  _roomMusic = null;
                  _persistentObject.muteChanged(SBAudio.isMusicMuted);
               }
               return;
            }
            _roomMusic.playNewMusic(param1,true,param2);
            if(SBAudio.isMusicMuted)
            {
               _roomMusic.toggleMute();
            }
         }
      }
      
      public function debugAudioVolumeChanged(param1:Number) : void
      {
         if(_roomMusic)
         {
            _roomMusic.volume = param1;
         }
      }
      
      public function get roomMusic() : SBMusic
      {
         return _roomMusic;
      }
      
      public function set customMusicDef(param1:int) : void
      {
         _customMusicDef = param1;
      }
      
      public function get customMusicDef() : int
      {
         return _customMusicDef;
      }
      
      private function onRoomEvent(param1:RoomEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         switch(param1.type)
         {
            case "RoomEventLoadSfx":
               _loc2_ = int(param1.secondaryType);
               if(_loc2_ > 0)
               {
                  loadRoomEventSfx(int(param1.secondaryType));
               }
               break;
            case "RoomEventPlaySfx":
               playRoomEventSfx(param1.secondaryType);
               break;
            case "RoomEventPlaySwfSfx":
               _loc3_ = _scene.getLayer(param1.secondaryType);
               if(_loc3_)
               {
                  if(!SBAudio.isMusicMuted)
                  {
                     _loc3_.loader.content.playSound(param1.tertiaryType);
                  }
                  if(param1.persistent)
                  {
                     _persistentObject = _loc3_.loader.content;
                     _roomMusic = null;
                  }
               }
               break;
            case "RoomEventPlaySwfSfxByClass":
               if(!SBAudio.isMusicMuted)
               {
                  param1.target.playSound();
               }
               break;
            case "RoomEventAttachEmote":
               AvatarManager.setPlayerAttachmentEmot(parseInt(param1.secondaryType));
         }
      }
      
      public function loadRoomEventSfx(param1:int) : void
      {
         var _loc2_:MediaHelper = null;
         if(_sfxMediaHelpers[param1] == null)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(param1,onSfxLoaded,true);
            _sfxMediaHelpers[param1] = _loc2_;
         }
      }
      
      private function playRoomEventSfx(param1:String) : void
      {
         if(param1 != "aj_water_fs1" && param1 != "aj_water_fs2" && param1 != "aj_water_fs3" && param1 != "ITEM_GROW" && param1 != "ITEM_SHRINK")
         {
            SBAudio.playCachedSound(param1);
         }
      }
      
      private function onSfxLoaded(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc6_:String = null;
         var _loc2_:Array = getDefinitionNames(param1.loaderInfo);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc4_];
            if(_loc6_ && _loc6_ != "")
            {
               SBAudio.addCachedSound(_loc6_,param1.loaderInfo.applicationDomain.getDefinition(_loc6_) as Class);
            }
            _loc4_++;
         }
         var _loc5_:int = int(param1.mediaHelper.id);
         _sfxMediaHelpers[_loc5_].destroy();
         delete _sfxMediaHelpers[_loc5_];
      }
      
      public function collisionTestGrid(param1:int, param2:int) : uint
      {
         if(!_mainBackObj)
         {
            return 0;
         }
         var _loc3_:Object = _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
         return _roomGrid.testGridCell(_loc3_.x,_loc3_.y);
      }
      
      public function getGridXY(param1:int, param2:int) : Object
      {
         if(!_mainBackObj)
         {
            return null;
         }
         return _roomGrid.convertWorldPosToGrid(param1 + _mainBackObj.x,param2 + _mainBackObj.y);
      }
      
      public function enableVolume(param1:String, param2:Boolean) : void
      {
         _roomGrid.enableVolume(param1,param2);
         _volumeManager.setVolumesEnabled(param1,param2);
      }
      
      public function rebuildGrid() : void
      {
         if(_grid.hasOwnProperty("packedGrid"))
         {
            _grid.packedGrid.position = 0;
         }
         _roomGrid.setGrid(_grid);
      }
      
      public function scrollRoom(param1:Point, param2:int, param3:Number) : Boolean
      {
         var _loc4_:Number = param1.x;
         var _loc6_:Number = param1.y;
         var _loc7_:Number = calcScrollAmount(_loc4_,_layerManager.bkg.scaleX,400,900,_mainBackObj.dx,param2);
         var _loc5_:Number = calcScrollAmount(_loc6_,_layerManager.bkg.scaleY,250,550,_mainBackObj.dy,param2);
         _scrollOffset.x += _loc7_;
         _scrollOffset.y += _loc5_;
         if(_loc7_ || _loc5_)
         {
            if(updateBackground())
            {
               return true;
            }
         }
         return _loc7_ == 0 && _loc5_ == 0;
      }
      
      protected function calcScrollAmount(param1:Number, param2:Number, param3:int, param4:int, param5:Number, param6:int, param7:Boolean = false) : Number
      {
         var _loc8_:* = 0;
         var _loc10_:int = param6 * 1.5;
         var _loc11_:Number = param3 - param1;
         var _loc9_:Number = param1 - (param4 - param3);
         if(param7)
         {
            param6 = Math.max(_loc9_,_loc11_);
         }
         if(_loc9_ > 0)
         {
            _loc8_ = param6;
            if(_loc9_ < _loc8_)
            {
               _loc8_ = _loc9_;
            }
            _loc8_ *= -1;
         }
         else if(_loc11_ > 0)
         {
            _loc8_ = param6;
            if(_loc11_ < _loc8_)
            {
               _loc8_ = _loc11_;
            }
         }
         if(param5 != 1)
         {
            _loc8_ /= param5;
         }
         if(_loc8_ != 0 && param2 != 1)
         {
            _loc8_ /= param2;
         }
         return _loc8_;
      }
      
      public function updateBackground(param1:Boolean = false) : Boolean
      {
         var _loc11_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc10_:Object = null;
         var _loc6_:Loader = null;
         var _loc7_:int = 0;
         var _loc12_:Number = _scrollOffset.x;
         var _loc14_:Number = _scrollOffset.y;
         if(_loc14_ > -_stageMin.y)
         {
            _loc14_ = -_stageMin.y;
            _loc11_ = true;
         }
         else if(_loc14_ < -_stageMax.y + 230 * (1 - _layerManager.bkg.scaleX) / 0.3)
         {
            _loc14_ = -_stageMax.y + 230 * (1 - _layerManager.bkg.scaleX) / 0.3;
            _loc11_ = true;
         }
         if(_loc12_ > -_stageMin.x)
         {
            _loc12_ = -_stageMin.x;
            _loc11_ = true;
         }
         else if(_loc12_ < -_stageMax.x + 385 * (1 - _layerManager.bkg.scaleX) / 0.3)
         {
            _loc12_ = -_stageMax.x + 385 * (1 - _layerManager.bkg.scaleX) / 0.3;
            _loc11_ = true;
         }
         if(_loc11_)
         {
            if(_numTimesForceChangedBgPos < 3)
            {
               _numTimesForceChangedBgPos++;
               _loc11_ = false;
            }
         }
         _scrollOffset.x = _loc12_;
         _scrollOffset.y = _loc14_;
         if(_buckets)
         {
            setActiveBuckets();
         }
         var _loc3_:uint = 0;
         var _loc9_:DisplayLayer = _layerManager.room_bkg_group;
         var _loc4_:DisplayLayer = _layerManager.room_chat;
         var _loc16_:SortLayer = _layerManager.flying_avatars;
         var _loc5_:DisplayLayer = _layerManager.room_orbs;
         var _loc8_:SortLayer = _layerManager.preview_room_flying_avatar;
         var _loc2_:int = int(_layers.length);
         _loc7_ = 0;
         while(_loc7_ < _loc2_)
         {
            _loc10_ = _layers[_loc7_];
            _loc6_ = _loc10_.s;
            if(_loc10_.layer != 1)
            {
               _loc15_ = _loc10_.x + _loc12_ * _loc10_.dx;
               _loc13_ = _loc10_.y + _loc14_ * _loc10_.dy;
               if(_loc6_ == _mainBackObj.s)
               {
                  _loc9_.x = _loc15_ - _loc10_.x;
                  _loc9_.y = _loc13_ - _loc10_.y;
                  _loc4_.x = _loc15_;
                  _loc4_.y = _loc13_;
                  _loc16_.x = _loc15_;
                  _loc16_.y = _loc13_;
                  _loc5_.x = _loc15_;
                  _loc5_.y = _loc13_;
                  _loc8_.x = _loc15_;
                  _loc8_.y = _loc13_;
               }
               if(!_loc10_.flip)
               {
                  _loc6_.x = _loc15_;
                  _loc6_.y = _loc13_;
               }
               else
               {
                  setLayerMatrix(_loc10_.s,_loc10_.flip,_loc10_.scaleX,_loc10_.scaleY,_loc10_.width,_loc10_.height,_loc15_,_loc13_);
               }
            }
            if(_assetsLoaded && _loc10_.excludeFromCull != 1 && _loc6_)
            {
               if(!_buckets || _buckets[_loc10_.bucketIndex].active)
               {
                  _loc3_ += checkStageValidity(_loc10_);
               }
            }
            _loc7_++;
         }
         if(!param1 && _checkSurroundingAssets && _loc3_ == 0)
         {
            _scene.forceLoadComplete();
            _checkSurroundingAssets = false;
         }
         return _loc11_;
      }
      
      private function setActiveBuckets() : void
      {
         var _loc1_:Object = null;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = _layerManager.bkg.scaleX;
         _loc6_ = 0;
         while(_loc6_ < _buckets.length)
         {
            _loc1_ = _buckets[_loc6_];
            _loc9_ = _loc1_.x + (_scrollOffset.x - _loc1_.scrollOffsetX) * _loc7_;
            _loc5_ = _loc1_.x + _loc1_.width + (_scrollOffset.x - _loc1_.scrollOffsetX) * _loc7_;
            _loc11_ = _loc1_.y + (_scrollOffset.y - _loc1_.scrollOffsetY) * _loc7_;
            _loc2_ = _loc1_.y + _loc1_.height + (_scrollOffset.y - _loc1_.scrollOffsetY) * _loc7_;
            _loc1_.active = !(650 < _loc11_ || -100 > _loc2_ || 1000 < _loc9_ || -100 > _loc5_);
            _loc6_++;
         }
      }
      
      protected function checkStageValidity(param1:Object) : uint
      {
         var _loc7_:Sprite = null;
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(param1.layer == 1)
         {
            _loc7_ = _isDenPreview ? layerManager.preview_room_avatar : _layerManager.room_avatars;
            _loc2_ = _loc7_.parent.x;
            _loc4_ = _loc7_.parent.y;
         }
         else
         {
            _loc7_ = _layerManager.room_bkg;
         }
         _loc2_ += param1.offsetX;
         _loc4_ += param1.offsetY;
         var _loc10_:Number = _layerManager.bkg.scaleX;
         var _loc5_:int = int(param1.s.y);
         var _loc6_:int = int(param1.s.x);
         var _loc9_:int = _loc7_.y;
         var _loc8_:int = _loc7_.x;
         if(!(650 < (_loc5_ + _loc9_ + _loc4_) * _loc10_ || -100 > (_loc5_ + param1.height + _loc9_ + _loc4_) * _loc10_ || 1000 < (_loc6_ + _loc8_ + _loc2_) * _loc10_ || -100 > (_loc6_ + param1.width + _loc8_ + _loc2_) * _loc10_))
         {
            if(param1.loaded == 0)
            {
               if(_assetPool[param1.assetName] && _assetPool[param1.assetName].length > 0)
               {
                  swapObjects(param1,_assetPool[param1.assetName].pop());
               }
               else
               {
                  _scene.loadLayer(param1);
                  _loc3_ = 1;
               }
            }
            if(param1.s.parent == null)
            {
               if(param1.layer != 1)
               {
                  insertOrdered(param1);
               }
               else
               {
                  _isDenPreview ? layerManager.preview_room_avatar.addChild(param1.s) : _layerManager.room_avatars.addChild(param1.s);
               }
               _loc11_ = 0;
               if(_assetPool[param1.assetName] && (_loc11_ = int(_assetPool[param1.assetName].indexOf(param1))) != -1)
               {
                  _assetPool[param1.assetName].splice(_loc11_,1);
               }
            }
         }
         else if(param1.s.parent)
         {
            param1.s.parent.removeChild(param1.s);
            if(param1.loaded == 2 && _scene.isValidDynamicAsset(param1))
            {
               if(_assetPool[param1.assetName] == null)
               {
                  _assetPool[param1.assetName] = [];
               }
               _assetPool[param1.assetName].push(param1);
            }
         }
         return _loc3_;
      }
      
      private function swapObjects(param1:Object, param2:Object) : void
      {
         _objectSwapper.s = param1.s;
         param1.s = param2.s;
         param2.s = _objectSwapper.s;
         _parentIndices[param1.s] = param1.pIndex;
         _parentIndices[param2.s] = param2.pIndex;
         _objectSwapper.sx = param1.s.x;
         _objectSwapper.sy = param1.s.y;
         _objectSwapper.srotation = param1.s.rotation;
         _objectSwapper.sscaleX = param1.s.scaleX;
         _objectSwapper.sscaleY = param1.s.scaleY;
         _objectSwapper.loaded = param1.loaded;
         param1.s.x = param2.s.x;
         param1.s.y = param2.s.y;
         param1.s.rotation = param2.s.rotation;
         param1.s.scaleX = param2.s.scaleX;
         param1.s.scaleY = param2.s.scaleY;
         param1.loaded = param2.loaded;
         param2.s.x = _objectSwapper.sx;
         param2.s.y = _objectSwapper.sy;
         param2.s.rotation = _objectSwapper.srotation;
         param2.s.scaleX = _objectSwapper.sscaleX;
         param2.s.scaleY = _objectSwapper.sscaleY;
         param2.loaded = _objectSwapper.loaded;
      }
      
      private function insertOrdered(param1:Object) : void
      {
         var _loc2_:Sprite = null;
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         if(param1.layer == 0)
         {
            _loc2_ = _layerManager.room_bkg;
         }
         else if(param1.layer == 4)
         {
            _loc2_ = _layerManager.room_super_fg;
         }
         else
         {
            _loc2_ = _layerManager.room_fg;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_.numChildren)
         {
            _loc4_ = _loc2_.getChildAt(_loc3_);
            if(_parentIndices[_loc4_] > param1.pIndex)
            {
               break;
            }
            _loc3_++;
         }
         _loc2_.addChildAt(param1.s,_loc3_);
      }
      
      protected function setLayerMatrix(param1:Loader, param2:int, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : void
      {
         if(!param2)
         {
            param1.x = param7;
            param1.y = param8;
         }
         else
         {
            if(param2 & 1)
            {
               param1.scaleX = param3 * -1;
               param1.x = param7 + param5;
            }
            else
            {
               param1.x = param7;
            }
            if(param2 & 2)
            {
               param1.scaleY = param4 * -1;
               param1.y = param8 + param6;
            }
            else
            {
               param1.y = param8;
            }
         }
      }
      
      public function convertToWorldSpace(param1:Point) : void
      {
         if(_mainBackObj)
         {
            param1.x -= _mainBackObj.x;
            param1.y -= _mainBackObj.y;
         }
      }
      
      public function convertScreenToWorldSpace(param1:int, param2:int) : Point
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_mainBackObj)
         {
            _loc4_ = (param1 - _layerManager.bkg.x) / _layerManager.bkg.scaleX - (_mainBackObj.x + _mainBackObj.dx * _scrollOffset.x);
            _loc3_ = (param2 - _layerManager.bkg.y) / _layerManager.bkg.scaleY - (_mainBackObj.y + _mainBackObj.dy * _scrollOffset.y);
         }
         return new Point(_loc4_,_loc3_);
      }
      
      public function convertWorldToScreen(param1:int, param2:int) : Point
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(_mainBackObj)
         {
            _loc4_ = param1 + (_mainBackObj.x + _mainBackObj.dx * _scrollOffset.x) * _layerManager.bkg.scaleX + _layerManager.bkg.x;
            _loc3_ = param2 + (_mainBackObj.y + _mainBackObj.dy * _scrollOffset.y) * _layerManager.bkg.scaleY + _layerManager.bkg.y;
         }
         return new Point(_loc4_,_loc3_);
      }
      
      public function bkgScalePoint() : Point
      {
         return new Point(_layerManager.bkg.scaleX,_layerManager.bkg.scaleY);
      }
      
      protected function getRandomRadiusOffset(param1:Number) : Point
      {
         var _loc2_:Point = new Point();
         var _loc3_:Number = Math.random() * (2 * 3.141592653589793);
         param1 = Math.random() * param1;
         _loc2_.x = Math.cos(_loc3_) * param1;
         _loc2_.y = Math.sin(_loc3_) * param1;
         return _loc2_;
      }
      
      public function convertPathToWorldSpace() : void
      {
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         var _loc1_:Point = null;
         if(_paths)
         {
            _loc2_ = 0;
            while(_loc2_ < _paths.length)
            {
               _loc4_ = _paths[_loc2_];
               _loc3_ = 0;
               while(_loc3_ < _loc4_.points.length)
               {
                  if(_loc4_.points[_loc3_])
                  {
                     _loc1_ = new Point(_loc4_.points[_loc3_].x,_loc4_.points[_loc3_].y);
                     convertToWorldSpace(_loc1_);
                     _loc4_.points[_loc3_].x = _loc1_.x;
                     _loc4_.points[_loc3_].y = _loc1_.y;
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
         }
      }
      
      public function findPathByName(param1:String) : Object
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(_paths)
         {
            param1.toLowerCase();
            _loc2_ = 0;
            while(_loc2_ < _paths.length)
            {
               _loc3_ = _paths[_loc2_];
               if(_loc3_.name == param1)
               {
                  return _loc3_;
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      protected function clearDebugLayer() : void
      {
         if(_layerManager.debugShape.parent)
         {
            _layerManager.debugShape.parent.removeChild(_layerManager.debugShape);
         }
      }
      
      protected function drawDebugLayer(param1:Vector.<int> = null) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc14_:int = 0;
         var _loc12_:int = 0;
         var _loc9_:Object = null;
         var _loc8_:Object = null;
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         var _loc13_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc7_:int = 0;
         var _loc10_:Object = null;
         _layerManager.debugShape.x = -_mainBackObj.x;
         _layerManager.debugShape.y = -_mainBackObj.y;
         _layerManager.room_bkg_main.addChild(_layerManager.debugShape);
         var _loc4_:Graphics = _layerManager.debugShape.graphics;
         _loc4_.clear();
         if(_portals)
         {
            _loc4_.beginFill(16711680,0.2);
            _loc5_ = 0;
            while(_loc5_ < _portals.length)
            {
               _loc9_ = _portals[_loc5_];
               _loc4_.drawCircle(_loc9_.x,_loc9_.y,_loc9_.r);
               if(_loc9_.type == 1)
               {
                  _loc6_ = 0;
                  while(_loc6_ < _layers.length)
                  {
                     _loc8_ = _layers[_loc6_];
                     if(_loc8_.name == _loc9_["goto"])
                     {
                        break;
                     }
                     _loc6_++;
                  }
                  if(_loc8_)
                  {
                     _loc2_ = _loc8_.s.content;
                     if(_loc2_)
                     {
                        _loc6_ = 0;
                        while(_loc6_ < _loc2_.totalFrames)
                        {
                           _loc2_.gotoAndStop(_loc6_);
                           _loc12_ = _loc2_.player.x + _loc8_.x;
                           _loc14_ = _loc2_.player.y + _loc8_.y;
                           _loc4_.drawCircle(_loc12_,_loc14_,10);
                           _loc6_++;
                        }
                     }
                  }
               }
               _loc5_++;
            }
         }
         _loc4_.endFill();
         _loc4_.beginFill(65280,0.2);
         _loc5_ = 0;
         while(_loc5_ < _spawns.length)
         {
            _loc9_ = _spawns[_loc5_];
            _loc4_.drawCircle(_loc9_.x,_loc9_.y,_loc9_.r);
            _loc5_++;
         }
         _loc4_.endFill();
         if(_actionPoints)
         {
            _loc4_.beginFill(255,0.2);
            _loc5_ = 0;
            while(_loc5_ < _actionPoints.length)
            {
               _loc9_ = _actionPoints[_loc5_];
               _loc4_.drawCircle(_loc9_.x,_loc9_.y,_loc9_.r);
               _loc5_++;
            }
            _loc4_.endFill();
         }
         if(_lines)
         {
            _loc4_.lineStyle(2,16777215);
            _loc5_ = 0;
            while(_loc5_ < _lines.length)
            {
               _loc9_ = _lines[_loc5_];
               _loc4_.moveTo(_loc9_.x,_loc9_.y);
               _loc4_.lineTo(_loc9_.x1,_loc9_.y1);
               _loc5_++;
            }
         }
         if(_paths)
         {
            _loc4_.lineStyle(2,255);
            _loc5_ = 0;
            while(_loc5_ < _paths.length)
            {
               _loc9_ = _paths[_loc5_];
               _loc6_ = 0;
               while(_loc6_ < _loc9_.points.length)
               {
                  _loc3_ = _loc9_.points[_loc6_];
                  if(_loc6_ == 0)
                  {
                     _loc4_.moveTo(_loc3_.x,_loc3_.y);
                  }
                  else
                  {
                     _loc4_.lineTo(_loc3_.x,_loc3_.y);
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         if(_volumes)
         {
            _loc4_.lineStyle(2,255);
            _loc5_ = 0;
            while(_loc5_ < _volumes.length)
            {
               _loc9_ = _volumes[_loc5_];
               _loc6_ = 0;
               while(_loc6_ < _loc9_.points.length)
               {
                  _loc3_ = _loc9_.points[_loc6_];
                  if(_loc6_ == 0)
                  {
                     _loc4_.moveTo(_loc3_.x,_loc3_.y);
                  }
                  else
                  {
                     _loc4_.lineTo(_loc3_.x,_loc3_.y);
                  }
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         if(_grid)
         {
            _loc13_ = _grid.min.y + _grid.r;
            _loc14_ = 0;
            while(_loc14_ < _grid.height)
            {
               _loc15_ = _grid.min.x + _grid.r;
               _loc12_ = 0;
               while(_loc12_ < _grid.width)
               {
                  _loc4_.lineStyle(2,0);
                  _loc7_ = int(_grid.grid[_loc12_ + _loc14_ * _grid.width]);
                  if(_loc7_)
                  {
                     _loc4_.beginFill(_loc7_ == 1 ? 16776960 : 255,0.9);
                  }
                  _loc4_.drawRect(_loc15_ - _grid.r,_loc13_ - _grid.r,_grid.r2,_grid.r2);
                  _loc4_.endFill();
                  _loc15_ += _grid.r2;
                  _loc12_++;
               }
               _loc13_ += _grid.r2;
               _loc14_++;
            }
            if(param1)
            {
               _loc5_ = 0;
               while(_loc5_ < param1.length)
               {
                  _loc10_ = _roomGrid.getCellIndexToWorldPos(param1[_loc5_]);
                  _loc4_.beginFill(16711680,0.75);
                  _loc4_.drawRect(_loc10_.x - _grid.r,_loc10_.y - _grid.r,_grid.r2,_grid.r2);
                  _loc4_.endFill();
                  _loc5_++;
               }
            }
         }
      }
   }
}

