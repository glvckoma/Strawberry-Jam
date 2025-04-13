package gui
{
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyManager;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PlayerSearch
   {
      public static const SEARCH_MEDIA_ID:int = 396;
      
      public static const LOADING_SPIRAL_ID:int = 397;
      
      private var _searchPopup:MovieClip;
      
      private var _searchMediaHelper:MediaHelper;
      
      private var _lastSearchedName:String;
      
      private var _closeCallback:Function;
      
      public function PlayerSearch()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         _closeCallback = param1;
         DarkenManager.showLoadingSpiral(true);
         _searchMediaHelper = new MediaHelper();
         _searchMediaHelper.init(396,searchMediaCallback,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:Function = null;
         if(_closeCallback != null)
         {
            _loc1_ = _closeCallback;
            _closeCallback = null;
            _loc1_();
            return;
         }
         _searchMediaHelper.destroy();
         if(_searchPopup)
         {
            removeListeners();
            GuiManager.guiLayer.removeChild(_searchPopup);
            DarkenManager.unDarken(_searchPopup);
            _searchPopup = null;
         }
      }
      
      private function searchMediaCallback(param1:MovieClip) : void
      {
         _searchPopup = MovieClip(param1.getChildAt(0));
         _searchPopup.x = 900 * 0.5;
         _searchPopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_searchPopup);
         addListeners();
         setInitialConditions();
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_searchPopup);
         _searchMediaHelper = new MediaHelper();
         _searchMediaHelper.init(397,loadingSpiralCallback,true);
      }
      
      private function loadingSpiralCallback(param1:MovieClip) : void
      {
         if(_searchPopup)
         {
            _searchPopup.itemBlock.addChild(param1);
            _searchPopup.itemBlock.visible = false;
         }
      }
      
      private function setInitialConditions() : void
      {
         _searchPopup.userNameTxt.text = "";
         _searchPopup.userNameTxt.restrict = Utility.getUsernameRestrictions();
         _searchPopup.userNameTxt.maxChars = 32;
         gMainFrame.stage.focus = _searchPopup.userNameTxt;
         _searchPopup.notFoundTab.visible = false;
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onSearchBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         performSearch();
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            performSearch();
         }
      }
      
      private function performSearch() : void
      {
         var _loc1_:Buddy = null;
         _searchPopup.notFoundTab.visible = true;
         LocalizationManager.translateId(_searchPopup.notFoundTab.getChildAt(1),11369);
         var _loc3_:String = _searchPopup.userNameTxt.text;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc3_.toLowerCase())
         {
            LocalizationManager.translateId(_searchPopup.notFoundTab.getChildAt(1),11370);
            gMainFrame.stage.focus = _searchPopup.userNameTxt;
            return;
         }
         var _loc2_:String = _loc3_.toLowerCase();
         if(_lastSearchedName != _loc2_)
         {
            _lastSearchedName = _loc2_;
            _loc1_ = BuddyManager.getBuddyByUserName(_loc2_);
            if(_loc1_)
            {
               _searchPopup.notFoundTab.visible = false;
               BuddyManager.showBuddyCard({
                  "userName":_loc1_.userName,
                  "onlineStatus":_loc1_.onlineStatus
               });
               destroy();
            }
            else
            {
               _searchPopup.notFoundTab.visible = false;
               _searchPopup.itemBlock.visible = true;
               AvatarXtCommManager.requestAvatarGet(_loc3_,onUserLookUpReceived,true);
            }
         }
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:UserInfo = null;
         if(_searchPopup)
         {
            _searchPopup.itemBlock.visible = false;
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
            if(param2)
            {
               if(_loc4_)
               {
                  if(_loc4_.userNameModeratedFlag > 0 && param1.toLowerCase() == _searchPopup.userNameTxt.text.toLowerCase())
                  {
                     BuddyManager.showBuddyCard({
                        "userName":param1,
                        "onlineStatus":param3
                     });
                     destroy();
                  }
                  else
                  {
                     _searchPopup.notFoundTab.visible = true;
                     gMainFrame.stage.focus = _searchPopup.userNameTxt;
                  }
               }
               else
               {
                  BuddyManager.showBuddyCard({
                     "userName":param1,
                     "onlineStatus":param3
                  });
                  destroy();
               }
            }
            else if(param3 == -3)
            {
               destroy();
            }
            else
            {
               _searchPopup.notFoundTab.visible = true;
               gMainFrame.stage.focus = _searchPopup.userNameTxt;
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addListeners() : void
      {
         _searchPopup["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
         _searchPopup.searchBtn.addEventListener("mouseDown",onSearchBtnHandler,false,0,true);
         _searchPopup.userNameTxt.addEventListener("keyDown",keyDownListener,false,0,true);
         _searchPopup.addEventListener("mouseDown",onPopup,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _searchPopup["bx"].removeEventListener("mouseDown",popupCloseHandler);
         _searchPopup.searchBtn.removeEventListener("mouseDown",onSearchBtnHandler);
         _searchPopup.userNameTxt.removeEventListener("keyDown",keyDownListener);
         _searchPopup.addEventListener("mouseDown",onPopup,false,0,true);
      }
   }
}

