package gui.itemWindows
{
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyManager;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiRadioButtonSingle;
   import localization.LocalizationManager;
   
   public class ItemWindowBuddyList extends ItemWindowBase
   {
      private var _bud:Buddy = new Buddy();
      
      private var _isForMainHud:Boolean;
      
      private var _currWindow:MovieClip;
      
      private var _isSelection:Boolean;
      
      private var _currSelectedUsername:String;
      
      public function ItemWindowBuddyList(param1:Function, param2:*, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _bud.init(param2.userName,param2.uuid,param2.moderatedUserNameFlag,param2.onlineStatus,param2.accountType,param2.timeLeftHostingCustomParty);
         _isForMainHud = !!param9 ? param9.isForMainHud : false;
         _isSelection = !!param9 ? param9.isSelection : false;
         if(param9 && _bud.userName.toLowerCase() == param9.currSelectedUsername.toLowerCase())
         {
            _currSelectedUsername = param9.currSelectedUsername;
         }
         else
         {
            _currSelectedUsername = "";
         }
         super("buddyListWindowCont",param1,param2,param3,param4,param5,param6,param7,param8,false);
      }
      
      override public function destroy() : void
      {
         if(_window && _window.recycleBtn)
         {
            _window.recycleBtn.removeEventListener("mouseDown",onRecycleDown);
         }
         super.destroy();
      }
      
      public function getBuddy() : Buddy
      {
         return _bud;
      }
      
      public function buddyPortalUsername() : String
      {
         return _currSelectedUsername.toLowerCase();
      }
      
      public function turnOffBuddySelection() : void
      {
         _currSelectedUsername = "";
         _currWindow.selectPortalBuddyBox.selected = false;
      }
      
      public function setBuddySelection() : void
      {
         _currSelectedUsername = _bud.userName;
      }
      
      public function showRecycleBtn(param1:Boolean) : void
      {
         if(_window)
         {
            _window.recycleBtn.visible = param1;
            _window.highlight.visible = param1;
         }
      }
      
      public function get sizeCont() : MovieClip
      {
         return _window.sizeCont;
      }
      
      public function update() : void
      {
         if(_bud && _bud.onlineStatus == 1)
         {
            _bud = BuddyManager.getBuddyByUserName(_bud.userName);
            if(_bud && _window)
            {
               _currWindow = _window.OnlineBuddyListWindow;
               if(_currWindow && _currWindow.onOffBlocked.currentFrameLabel != "blocked")
               {
                  if(_bud.timeLeftHostingCustomParty > 0)
                  {
                     _currWindow.onOffBlocked.gotoAndStop("jammerParty");
                  }
                  else
                  {
                     _currWindow.onOffBlocked.gotoAndStop("online");
                  }
               }
            }
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_isSelection)
         {
            _window.gotoAndStop("portal");
            _currWindow = _window.portal;
            _currWindow.selectPortalBuddyBox = new GuiRadioButtonSingle(_currWindow.radioBtn,_currWindow.userNameTxt);
            if(_bud.onlineStatus == -1)
            {
               _currWindow.selectPortalBuddyBox.gray = true;
            }
            else if(_bud.userName.toLowerCase() == _currSelectedUsername.toLowerCase())
            {
               _currWindow.selectPortalBuddyBox.selected = true;
               BuddyList.updateSelectedInWorldBuddyIndex(_index);
            }
            else
            {
               _currWindow.selectPortalBuddyBox.selected = false;
            }
         }
         else
         {
            if(_bud.onlineStatus == 1)
            {
               _window.gotoAndStop("online");
               _currWindow = _window.OnlineBuddyListWindow;
               if(BuddyManager.isBlocked(_bud.userName))
               {
                  _currWindow.onOffBlocked.gotoAndStop("blocked");
               }
               else if(_bud.timeLeftHostingCustomParty > 0)
               {
                  _currWindow.onOffBlocked.gotoAndStop("jammerParty");
               }
               else
               {
                  _currWindow.onOffBlocked.gotoAndStop("online");
               }
            }
            else
            {
               _window.gotoAndStop("offline");
               _currWindow = _window.OfflineBuddyListWindow;
               _currWindow.onOffBlocked.gotoAndStop("offline");
            }
            _currWindow.onlineStatus = _bud.onlineStatus;
            _currWindow.accountType = _bud.accountType;
            _window.recycleBtn.addEventListener("mouseDown",onRecycleDown,false,0,true);
            _window.recycleBtn.visible = false;
            _window.highlight.visible = false;
         }
         _currWindow.userName = _bud.userName;
         _currWindow.moderatedUserName = _bud.userNameModerated;
         LocalizationManager.updateToFit(_currWindow.userNameTxt,_bud.userNameModerated);
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_bud)
         {
            new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14705,_bud.userNameModerated),true,removeBuddyConfirmCallback,{
               "currUserName":_bud.userName,
               "currUserNameModerated":_bud.userNameModerated
            });
         }
      }
      
      private function removeBuddyConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            setTimeout(DarkenManager.showLoadingSpiral,1000,false);
            BuddyManager.addRemoveBuddy(param1.passback.currUserName,param1.passback.currUserNameModerated,false);
         }
      }
   }
}

