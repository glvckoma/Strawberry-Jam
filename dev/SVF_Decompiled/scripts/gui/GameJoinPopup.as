package gui
{
   import avatar.UserCommXtCommManager;
   import com.greensock.TweenLite;
   import com.greensock.easing.Back;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.itemWindows.ItemWindowGameIcon;
   import loader.MediaHelper;
   
   public class GameJoinPopup
   {
      private static const JOIN_POPUP_ID:int = 4145;
      
      private static const GAME_LIST_ID:int = 341;
      
      private var _mediaHelper:MediaHelper;
      
      private var _joinPopup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _gameDefIds:Array;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _closeCallback:Function;
      
      private var _iconTween:TweenLite;
      
      private var _doubleGemsTween:TweenLite;
      
      public function GameJoinPopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _loadingSpiral = new LoadingSpiral();
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4145,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_joinPopup);
         if(_joinPopup && _guiLayer && _joinPopup.parent == _guiLayer)
         {
            _guiLayer.removeChild(_joinPopup);
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _mediaHelper.destroy();
         _mediaHelper = null;
         _joinPopup = param1.getChildAt(0) as MovieClip;
         _joinPopup.x = 900 * 0.5;
         _joinPopup.y = 550 * 0.5;
         _loadingSpiral.setNewParent(_joinPopup);
         buildItemWindows();
         addEventListeners();
         _guiLayer.addChild(_joinPopup);
         DarkenManager.darken(_joinPopup);
         _doubleGemsTween = null;
         _iconTween = null;
      }
      
      private function buildItemWindows() : void
      {
         GenericListXtCommManager.requestGenericList(341,onGameListLoaded);
      }
      
      private function onGameListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         var _loc5_:int = 0;
         _gameDefIds = param2;
         var _loc4_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < _gameDefIds.length)
         {
            if(!MinigameManager.minigameInfoCache.getMinigameInfo(_gameDefIds[_loc5_]))
            {
               _loc4_.push(_gameDefIds[_loc5_]);
            }
            _loc5_++;
         }
         if(_loc4_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc4_,false,onMinigameInfoResponse);
         }
         else
         {
            _itemWindows = new WindowAndScrollbarGenerator();
            _itemWindows.init(_joinPopup.itemWindow.width,_joinPopup.itemWindow.height - 4,-2,0,4,Math.max(1,_gameDefIds.length / 4),0,10,14,7,7,ItemWindowGameIcon,_gameDefIds,"",0,{
               "mouseDown":onIconDown,
               "mouseOver":onIconOver,
               "mouseOut":onIconOut
            },null,onWindowsLoaded);
            _joinPopup.itemWindow.addChild(_itemWindows);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         onGameListLoaded(0,_gameDefIds,null);
      }
      
      private function onWindowsLoaded() : void
      {
         _loadingSpiral.destroy();
         _loadingSpiral = null;
      }
      
      private function onIconDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if((param1.currentTarget as ItemWindowGameIcon).isCancelVisible)
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
            MinigameManager.readySelfForQuickMinigame(null,false);
            MinigameManager.readySelfForPvpGame(null,"",false);
            GuiManager.grayOutHudItemsForPrivateLobby(false);
         }
         else
         {
            if((param1.currentTarget as ItemWindowGameIcon).readyForPVP)
            {
               MinigameManager.checkAndStartPvpGame((param1.currentTarget as ItemWindowGameIcon).minigameInfo);
            }
            else
            {
               MinigameManager.handleGameClick((param1.currentTarget as ItemWindowGameIcon).gameLaunchObject,null,false);
            }
            GuiManager.grayOutHudItemsForPrivateLobby(true,true);
         }
         onClosePopup(null);
      }
      
      private function onIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ItemWindowGameIcon = param1.currentTarget as ItemWindowGameIcon;
         if(_loc2_.currItem)
         {
            if(_itemWindows.isIndexInView(_loc2_.index))
            {
               _itemWindows.toolTip.init(_joinPopup,_loc2_.toolTipName,_loc2_.x + _itemWindows.boxWidth * 0.5 + _itemWindows.parent.x + _loc2_.itemXLocation,Math.min(200,_loc2_.y + _itemWindows.boxHeight - _loc2_.itemYLocation + _itemWindows.parent.y - 5));
               _itemWindows.toolTip.startTimer(param1);
            }
            if(_iconTween)
            {
               _iconTween.progress(0);
            }
            if(_doubleGemsTween)
            {
               _doubleGemsTween.progress(0);
            }
            _iconTween = new TweenLite(_loc2_.currItem,0.15,{
               "scaleX":1.1,
               "scaleY":1.1,
               "ease":Back.easeIn
            });
            _doubleGemsTween = new TweenLite(_loc2_.extraGems(),0.15,{
               "scaleX":1.1,
               "scaleY":1.1,
               "ease":Back.easeIn
            });
         }
      }
      
      private function onIconOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _itemWindows.toolTip.resetTimerAndSetVisibility();
         var _loc2_:ItemWindowGameIcon = param1.currentTarget as ItemWindowGameIcon;
         if(_loc2_.currItem)
         {
            if(_iconTween)
            {
               _iconTween.progress(1);
            }
            if(_doubleGemsTween)
            {
               _doubleGemsTween.progress(1);
            }
            _iconTween = new TweenLite(_loc2_.currItem,0.15,{
               "scaleX":1,
               "scaleY":1,
               "ease":Back.easeOut
            });
            _doubleGemsTween = new TweenLite(_loc2_.extraGems(),0.15,{
               "scaleX":1,
               "scaleY":1,
               "ease":Back.easeOut
            });
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClosePopup(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function addEventListeners() : void
      {
         _joinPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _joinPopup.bx.addEventListener("mouseDown",onClosePopup,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _joinPopup.removeEventListener("mouseDown",onPopup);
         _joinPopup.bx.removeEventListener("mouseDown",onClosePopup);
      }
   }
}

