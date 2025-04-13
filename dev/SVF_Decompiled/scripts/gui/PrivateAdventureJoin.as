package gui
{
   import avatar.AvatarManager;
   import buddy.BuddyManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowCustPlayers;
   import loader.MediaHelper;
   import quest.QuestXtCommManager;
   
   public class PrivateAdventureJoin
   {
      private const MEDIA_ID:int = 2300;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _inParamsWaiting:Object;
      
      private var _waitingAvatarWindows:WindowGenerator;
      
      private var _windowScrollbar:SBScrollbar;
      
      private var _scriptDefId:int;
      
      public function PrivateAdventureJoin()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         if(GuiManager.chatHist)
         {
            GuiManager.chatHist.removeEmotesFromChatRepeat();
         }
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param2;
         _scriptDefId = param1;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2300,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         GuiManager.grayOutHudItemsForPrivateLobby(false);
         GuiManager.mainHud.emotesBtn.activateGrayState(false);
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         _guiLayer.removeChild(_popup);
      }
      
      public function handleWaitResponse(param1:Object) : void
      {
         var _loc2_:Array = null;
         if(_popup)
         {
            if(_waitingAvatarWindows)
            {
               _waitingAvatarWindows.destroy();
               _waitingAvatarWindows = null;
            }
            _loc2_ = param1.slice(2);
            _waitingAvatarWindows = new WindowGenerator();
            _waitingAvatarWindows.init(1,4,_loc2_.length,0,0,0,ItemWindowCustPlayers,param1.slice(2),"",{
               "mouseDown":onWindowDown,
               "mouseOver":onWindowOver,
               "mouseOut":onWindowOut,
               "memberOnlyMouseDown":null
            },{
               "onBxBtn":onKickPlayerBtn,
               "scriptDefId":_scriptDefId
            },onWindowLoaded,false,false);
         }
         else
         {
            _inParamsWaiting = param1;
         }
      }
      
      public function updateDisplayIndex(param1:Boolean = true) : void
      {
         var _loc2_:int = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
         var _loc3_:int = _popup.parent.getChildIndex(_popup);
         if(param1)
         {
            if(_loc2_ < _loc3_)
            {
               _popup.parent.setChildIndex(_popup,_loc2_);
            }
         }
         else if(_loc2_ > _loc3_)
         {
            _popup.parent.setChildIndex(_popup,_loc2_);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            GuiManager.mainHud.emotesBtn.activateGrayState(true);
            DarkenManager.showLoadingSpiral(false);
            _popup = MovieClip(param1.getChildAt(0));
            addEventListeners();
            _popup.x = _popup.width * 0.5;
            _popup.y = 255;
            _guiLayer.addChild(_popup);
            GuiManager.closeAnyHudPopups();
            if(_inParamsWaiting != null)
            {
               handleWaitResponse(_inParamsWaiting);
               _inParamsWaiting = null;
            }
            else
            {
               _waitingAvatarWindows = new WindowGenerator();
               _waitingAvatarWindows.init(1,4,1,0,0,0,ItemWindowCustPlayers,[AvatarManager.playerSfsUserId],"",{
                  "mouseDown":onWindowDown,
                  "mouseOver":onWindowOver,
                  "mouseOut":onWindowOut,
                  "memberOnlyMouseDown":null
               },{"onBxBtn":onKickPlayerBtn},onWindowLoaded,false,false);
            }
         }
      }
      
      private function onWindowLoaded() : void
      {
         if(_popup.playerWindow.numChildren > 0)
         {
            _popup.playerWindow.removeChildAt(0);
         }
         _popup.playerWindow.addChild(_waitingAvatarWindows);
         if(_windowScrollbar)
         {
            _windowScrollbar.destroy();
            _windowScrollbar = null;
         }
         _windowScrollbar = new SBScrollbar();
         _windowScrollbar.init(_waitingAvatarWindows,_waitingAvatarWindows.width,_waitingAvatarWindows.boxHeight * 4 + 0 + 0,10,"scrollbar2",_waitingAvatarWindows.boxHeight + 0);
      }
      
      private function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback(false);
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onWindowDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            BuddyManager.showBuddyCard({
               "userName":param1.currentTarget.userName,
               "onlineStatus":true
            });
         }
      }
      
      private function onWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            param1.currentTarget.char.gotoAndStop("over");
            param1.currentTarget.showXBtn(true);
         }
      }
      
      private function onWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.char.gotoAndStop("up");
         if(param1.currentTarget.userName != gMainFrame.userInfo.myUserName)
         {
            param1.currentTarget.showXBtn(false);
         }
      }
      
      private function onKickPlayerBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestPrivateKick(param1.currentTarget.parent.parent.userName);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPopupOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         updateDisplayIndex(false);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
         close();
      }
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestStartRequest();
         close();
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _popup.playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
         _popup.addEventListener("mouseOver",onPopupOver,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.bx.removeEventListener("mouseDown",onCloseBtn);
         _popup.playBtn.removeEventListener("mouseDown",onPlayBtn);
         _popup.removeEventListener("mouseOver",onPopupOver);
      }
   }
}

