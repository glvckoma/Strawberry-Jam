package gui
{
   import Party.PartyManager;
   import customParty.CustomPartyCreatePopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class PartyPreviewManager
   {
      private var _createPopup:CustomPartyCreatePopup;
      
      private var _hostAndBackBtns:MovieClip;
      
      private var _loadingMediaHelper:MediaHelper;
      
      public function PartyPreviewManager()
      {
         super();
      }
      
      public function setCreatePopup(param1:CustomPartyCreatePopup) : void
      {
         _createPopup = param1;
      }
      
      public function destroy() : void
      {
         if(_hostAndBackBtns)
         {
            _hostAndBackBtns.backBtn.removeEventListener("mouseDown",onBackBtn);
            _hostAndBackBtns.buyBtn.removeEventListener("mouseDown",onHostBtn);
            GuiManager.guiLayer.removeChild(_hostAndBackBtns);
            if(_hostAndBackBtns && _hostAndBackBtns.visible)
            {
               handlePartyPurchase(true);
            }
         }
      }
      
      public function handleAllRequiredVisibilities(param1:Boolean) : void
      {
         GuiManager.toggleHud();
         handlePartyAndCustomCreateVisibility(param1);
         if(_hostAndBackBtns)
         {
            _hostAndBackBtns.visible = !param1;
         }
         else if(!param1)
         {
            showBuyAndBackBtns(true);
         }
      }
      
      public function handlePartyPurchase(param1:Boolean = false) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
         }
         if(_hostAndBackBtns && _hostAndBackBtns.visible)
         {
            _hostAndBackBtns.visible = false;
         }
      }
      
      public function showBuyAndBackBtns(param1:Boolean) : void
      {
         if(param1)
         {
            if(_hostAndBackBtns)
            {
               _hostAndBackBtns.visible = true;
            }
            else
            {
               _loadingMediaHelper = new MediaHelper();
               _loadingMediaHelper.init(2969,onHostAndBackBtnsLoaded);
            }
         }
         else if(_hostAndBackBtns)
         {
            _hostAndBackBtns.visible = false;
         }
      }
      
      public function exitPreview() : void
      {
         onBackBtn(null);
      }
      
      private function handlePartyAndCustomCreateVisibility(param1:Boolean) : void
      {
         if(param1)
         {
            PartyManager.showPartyPopup(true);
            if(_createPopup)
            {
               _createPopup.showPopup(true);
            }
         }
      }
      
      private function onHostAndBackBtnsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _hostAndBackBtns = param1;
            _hostAndBackBtns.backBtn.addEventListener("mouseDown",onBackBtn,false,0,true);
            _hostAndBackBtns.buyBtn.addEventListener("mouseDown",onHostBtn,false,0,true);
            _hostAndBackBtns.buyBtn.visible = false;
            LocalizationManager.translateId(_hostAndBackBtns.buyBtn.mouse.mouse.txt,24223,false,false);
            LocalizationManager.translateId(_hostAndBackBtns.buyBtn.mouse.up.txt,24223,false,false);
            LocalizationManager.translateId(_hostAndBackBtns.buyBtn.down.txt,24223,false,false);
            GuiManager.guiLayer.addChild(_hostAndBackBtns);
         }
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_hostAndBackBtns && _hostAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _hostAndBackBtns.visible = false;
         }
      }
      
      private function onHostBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_createPopup)
         {
            _createPopup.tryToHostPartyFromPreview();
         }
      }
   }
}

