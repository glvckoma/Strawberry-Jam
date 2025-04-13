package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBPopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowServer;
   import localization.LocalizationManager;
   import room.RoomJoinType;
   import room.RoomXtCommManager;
   
   public class ServerSelector
   {
      private static const NUM_Y_WIN:int = 10;
      
      private static var _popupLayer:DisplayObjectContainer;
      
      private static var _closeCallback:Function;
      
      private static var _serverAllContent:MovieClip;
      
      private static var _serverAll:MovieClip;
      
      private static var _scrollButtons:SBScrollbar;
      
      private static var _itemWindows:WindowGenerator;
      
      private static var _serverAllPopup:SBPopup;
      
      private static var _availShards:Array;
      
      private static var _serverNames:Array;
      
      private static var _numBuddies:Array;
      
      private static var _languageIds:Array;
      
      private static var _popuplation:Array;
      
      private static var _nameIdx:int;
      
      private static var _lastClickedShardTarget:Object;
      
      public function ServerSelector()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer, param2:Object, param3:Function = null, param4:int = 450, param5:int = 275) : void
      {
         _popupLayer = param1;
         _lastClickedShardTarget = null;
         _closeCallback = param3;
         _availShards = [];
         _numBuddies = [];
         _languageIds = [];
         _popuplation = [];
         _nameIdx = 0;
         _serverAllContent = GETDEFINITIONBYNAME("ServerAllPopupContent");
         _serverAllPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ServerAllPopupSkin"),_serverAllContent,true,true,false,false,true);
         _serverAllPopup.bxClosesPopup = false;
         _serverAllPopup.x = param4;
         _serverAllPopup.y = param5;
         DarkenManager.showLoadingSpiral(true);
         MovieClip(_serverAllPopup.content).helpNameBtn.visible = false;
         fillNamesArray();
         SBTracker.trackPageview("/game/play/shardDetail");
         addListeners();
      }
      
      public static function isOpen() : Boolean
      {
         if(_serverAllPopup)
         {
            return _serverAllPopup.visible;
         }
         return false;
      }
      
      public static function destroy() : void
      {
         removeListeners();
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_serverAllPopup)
         {
            _serverAllPopup.x = undefined;
            _serverAllPopup.y = undefined;
            _serverAllPopup.destroy();
            _serverAllPopup = null;
         }
         _closeCallback = null;
      }
      
      public static function setupAllShards(param1:Object, param2:int) : void
      {
         var _loc7_:* = false;
         var _loc3_:int = 0;
         var _loc10_:* = 0;
         var _loc9_:* = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:int = -1;
         var _loc4_:int = 0;
         var _loc5_:int = LocalizationManager.accountLanguage;
         _availShards = [];
         _languageIds = [];
         _popuplation = [];
         _numBuddies = [];
         while(param1[_loc6_] != null)
         {
            _loc7_ = param1[_loc6_ + 2] == 0;
            if(_loc7_)
            {
               _loc4_++;
            }
            if(_loc7_ && _loc4_ > 5)
            {
               if(_loc11_ == -1)
               {
                  _loc11_ = int(param1[_loc6_]);
               }
               _loc6_ += 4;
            }
            else
            {
               _availShards[_loc8_] = param1[_loc6_++];
               _languageIds[_loc8_] = param1[_loc6_++];
               _loc3_ += int(param1[_loc6_]);
               _popuplation[_loc8_] = param1[_loc6_++];
               _numBuddies[_loc8_] = param1[_loc6_++];
               _loc8_++;
            }
         }
         if(_loc3_ >= _availShards.length * 4 && _loc8_ < _serverNames.length)
         {
            if(_loc11_ == -1)
            {
               _loc10_ = param2 + 1;
               _loc9_ = _loc5_;
            }
            else
            {
               _loc10_ = _loc11_;
               _loc9_ = int(_languageIds[_loc11_]);
            }
            _availShards.splice(0,0,String(_loc10_));
            _languageIds.splice(0,0,String(_loc9_));
            _popuplation.splice(0,0,"0");
            _numBuddies.splice(0,0,"0");
         }
         createServerButtons();
      }
      
      public static function getShardName(param1:int) : String
      {
         var _loc2_:int = param1 - 1;
         if(_serverNames)
         {
            if(0 <= _loc2_)
            {
               return LocalizationManager.translateIdOnly(_serverNames[_loc2_ % _serverNames.length]);
            }
            return LocalizationManager.translateIdOnly(_serverNames[0]);
         }
         return "Nullandria" + param1;
      }
      
      public static function fillNamesArray(param1:Boolean = false) : void
      {
         if(_serverNames == null || _serverNames.length == 0)
         {
            GenericListXtCommManager.requestGenericList(16,onShardNamesCallback,null,param1);
         }
         else
         {
            RoomXtCommManager.sendMoreShardRequest();
         }
      }
      
      public static function updatePopulationForRoomFullError() : void
      {
         if(_lastClickedShardTarget)
         {
            _lastClickedShardTarget.population = "4";
         }
      }
      
      private static function setupMoreServers(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = (_availShards[_nameIdx] - 1) % _serverNames.length;
         if(_loc2_ < _serverNames.length)
         {
            LocalizationManager.translateId(param1.textField,_serverNames[_loc2_]);
            if(_numBuddies[param1.index] > 0)
            {
               param1.buddy = true;
            }
            else
            {
               param1.buddy = false;
            }
            _loc3_ = int(_languageIds[param1.index]);
            if(_loc3_ == LocalizationManager.LANG_ENG)
            {
               _loc3_ = LocalizationManager.LANG_BLANK;
            }
            param1.flag = _loc3_ + 1;
            if(_popuplation[param1.index] > 0)
            {
               param1.population = _popuplation[param1.index];
            }
            else
            {
               param1.population = "0";
            }
            _nameIdx++;
            return;
         }
         _nameIdx = 0;
         setupMoreServers(param1);
      }
      
      private static function createServerButtons() : void
      {
         var _loc3_:int = 0;
         var _loc1_:MovieClip = null;
         if(_scrollButtons)
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(_itemWindows && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         var _loc4_:int = int(_availShards.length);
         var _loc5_:int = Math.min(_loc4_,2);
         var _loc2_:int = Math.min(_loc4_,10);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(_loc5_,_loc2_,_loc4_,20,8,10,ItemWindowServer,null,"",{"mouseDown":winMouseDown},null,null,false,false);
         _serverAllContent.itemBlock.addChild(_itemWindows);
         _itemWindows.x = 0;
         _itemWindows.y = 0;
         _nameIdx = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc1_ = MovieClip(_itemWindows.bg.getChildAt(_loc3_));
            setupMoreServers(_loc1_);
            _loc3_++;
         }
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,_serverAllContent.itemBlock.width - 31,_itemWindows.boxHeight * 10 + 8 * 10,0,"scrollbar2",_itemWindows.boxHeight + 8);
         DarkenManager.showLoadingSpiral(false);
      }
      
      private static function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         _lastClickedShardTarget = param1.currentTarget;
         if(param1.currentTarget.full)
         {
            if(_closeCallback != null)
            {
               _closeCallback(_availShards[param1.currentTarget.index],null,RoomJoinType.DIRECT_JOIN_AND_SEARCH_ON_FAILURE);
            }
         }
         else if(_closeCallback != null)
         {
            _closeCallback(_availShards[param1.currentTarget.index],null,RoomJoinType.DIRECT_JOIN_AND_SEARCH_ON_FAILURE);
         }
      }
      
      private static function onShardNamesCallback(param1:int, param2:Array) : void
      {
         _serverNames = param2;
      }
      
      private static function onCloseBtn(param1:MouseEvent) : void
      {
         destroy();
      }
      
      private static function onNamesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function addListeners() : void
      {
         _serverAllPopup.skin.s["bx"].addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         _serverAllPopup.skin.s["bx"].removeEventListener("mouseDown",onCloseBtn);
      }
   }
}

