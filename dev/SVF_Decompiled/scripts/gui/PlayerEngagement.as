package gui
{
   import com.sbi.analytics.SBTracker;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PlayerEngagement
   {
      private var _engagementMediaHelper:MediaHelper;
      
      private var _closeCallBack:Function;
      
      private var _engagementPopup:MovieClip;
      
      private var _currShardId:int;
      
      public function PlayerEngagement()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _currShardId = RoomManagerWorld.instance.shardId;
         _engagementMediaHelper = new MediaHelper();
         _engagementMediaHelper.init(1567,onEngagementLoaded);
         _closeCallBack = param1;
      }
      
      public function destroy(param1:Boolean = false, param2:Boolean = false) : void
      {
         if(!param2)
         {
            GuiManager.closePlayerEngagement(param1);
         }
         else
         {
            removeEventListeners();
            DarkenManager.unDarken(_engagementPopup);
            GuiManager.guiLayer.removeChild(_engagementPopup);
            _engagementPopup = null;
            if(_closeCallBack != null)
            {
               _closeCallBack(param1);
               _closeCallBack = null;
            }
            GuiManager.setupInGameRedemptions();
         }
      }
      
      private function onEngagementLoaded(param1:MovieClip) : void
      {
         _engagementMediaHelper.destroy();
         _engagementPopup = MovieClip(param1.getChildAt(0));
         _engagementPopup.x = 900 * 0.5;
         _engagementPopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_engagementPopup);
         _engagementPopup.gotoAndStop("new");
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_engagementPopup);
         addEventListeners();
      }
      
      private function onDenBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#den",-1,1);
         DenXtCommManager.requestDenJoinFull("den" + gMainFrame.userInfo.myUserName);
         destroy();
      }
      
      private function onVideoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#video",-1,1);
         RoomXtCommManager.sendNonDenRoomJoinRequest("sarepia.movie_theater#" + _currShardId);
         destroy();
      }
      
      private function onShoppingBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#shopping",-1,1);
         RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.clothes_shop#" + _currShardId);
         destroy();
      }
      
      private function onGamesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#games",-1,1);
         GuiManager.openJoinGamesPopup();
         destroy();
      }
      
      private function onAdventureBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#adventure",-1,1);
         RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_421_0_585#" + RoomManagerWorld.instance.shardId);
         destroy();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/playerEngagement/#close",-1,1);
         destroy();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         _engagementPopup.denBtn.addEventListener("mouseDown",onDenBtn,false,0,true);
         if(_engagementPopup.videoBtn)
         {
            _engagementPopup.videoBtn.addEventListener("mouseDown",onVideoBtn,false,0,true);
         }
         if(_engagementPopup.shoppingBtn)
         {
            _engagementPopup.shoppingBtn.addEventListener("mouseDown",onShoppingBtn,false,0,true);
         }
         _engagementPopup.gamesBtn.addEventListener("mouseDown",onGamesBtn,false,0,true);
         _engagementPopup.advBtn.addEventListener("mouseDown",onAdventureBtn,false,0,true);
         _engagementPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _engagementPopup.addEventListener("mouseDown",onPopup,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _engagementPopup.denBtn.removeEventListener("mouseDown",onDenBtn);
         if(_engagementPopup.videoBtn)
         {
            _engagementPopup.videoBtn.removeEventListener("mouseDown",onVideoBtn);
         }
         if(_engagementPopup.shoppingBtn)
         {
            _engagementPopup.shoppingBtn.removeEventListener("mouseDown",onShoppingBtn);
         }
         _engagementPopup.gamesBtn.removeEventListener("mouseDown",onGamesBtn);
         _engagementPopup.advBtn.removeEventListener("mouseDown",onAdventureBtn);
         _engagementPopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _engagementPopup.removeEventListener("mouseDown",onPopup);
      }
   }
}

