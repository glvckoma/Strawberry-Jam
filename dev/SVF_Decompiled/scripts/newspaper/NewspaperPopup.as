package newspaper
{
   import Party.PartyManager;
   import achievement.AchievementXtCommManager;
   import collection.NewspaperDefCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.DarkenManager;
   import gui.ExternalLinkPopup;
   import gui.FeedbackManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.ImagePoll;
   import gui.LoadingSpiral;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowToggleImage;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class NewspaperPopup
   {
      private const POPUP_ID:int = 5836;
      
      private var _popup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _bx:MovieClip;
      
      private var _paperItemWindow:MovieClip;
      
      private var _iconsItemWindow:MovieClip;
      
      private var _arrowLBtn:MovieClip;
      
      private var _arrowRBtn:MovieClip;
      
      private var _pageMouseOver:MovieClip;
      
      private var _leftBtn:MovieClip;
      
      private var _rightBtn:MovieClip;
      
      private var _loadingSpiralPaper:LoadingSpiral;
      
      private var _loadingSpiralIcon:LoadingSpiral;
      
      private var _iconWindows:WindowAndScrollbarGenerator;
      
      private var _defIds:Array;
      
      private var _newspaperDefs:NewspaperDefCollection;
      
      private var _currSelectedPage:int;
      
      private var _genericPopup:MovieClip;
      
      private var _gameLaunchObj:Object;
      
      private var _externalLinkPopup:ExternalLinkPopup;
      
      public function NewspaperPopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5836,onNewspaperPopupLoaded);
      }
      
      public function destroy() : void
      {
         if(_popup)
         {
            if(_iconWindows)
            {
               _iconWindows.destroy();
               _iconWindows = null;
            }
            removeEventListeners();
            DarkenManager.unDarken(_popup);
            GuiManager.guiLayer.removeChild(_popup);
            _popup = null;
            if(_closeCallback != null)
            {
               _closeCallback();
               _closeCallback = null;
            }
         }
      }
      
      private function onNewspaperPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _popup = MovieClip(param1.getChildAt(0));
         _bx = _popup.bx;
         _paperItemWindow = _popup.itemWindow;
         _iconsItemWindow = _popup.itemBlock;
         _arrowLBtn = _popup.arrowLBtn;
         _arrowRBtn = _popup.arrowRBtn;
         _pageMouseOver = _popup.page_MouseOver;
         _leftBtn = _popup.page_MouseOver.leftBtn;
         _rightBtn = _popup.page_MouseOver.rightBtn;
         addEventListeners();
         setupItemWindows();
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
      }
      
      private function setupItemWindows() : void
      {
         _loadingSpiralPaper = new LoadingSpiral(_paperItemWindow);
         _loadingSpiralIcon = new LoadingSpiral(_iconsItemWindow,_iconsItemWindow.width * 0.5,_iconsItemWindow.height * 0.5);
         NewspaperManager.loadNewspaperDefs(onNewspaperDefsLoaded);
      }
      
      private function onNewspaperDefsLoaded(param1:NewspaperDefCollection) : void
      {
         GenericListXtCommManager.requestGenericList(627,onListLoaded);
      }
      
      private function onListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _defIds = param2;
         onItemListFiltered();
      }
      
      private function onItemListFiltered() : void
      {
         var _loc1_:NewspaperDef = null;
         var _loc2_:int = 0;
         _newspaperDefs = new NewspaperDefCollection();
         _loc2_ = 0;
         while(_loc2_ < _defIds.length)
         {
            _loc1_ = NewspaperManager.getNewspaperDef(_defIds[_loc2_]);
            if(_loc1_ && (_loc1_.country == "" || _loc1_.country.indexOf(gMainFrame.clientInfo.countryCode) != -1) && _loc1_.getIsViewable(gMainFrame.userInfo.isMember))
            {
               _newspaperDefs.pushNewspaperDefItem(NewspaperManager.getNewspaperDef(_defIds[_loc2_]));
            }
            _loc2_++;
         }
         GenericListXtCommManager.filterTypedItems(_newspaperDefs);
         _iconWindows = new WindowAndScrollbarGenerator();
         _iconWindows.init(_iconsItemWindow.width,_iconsItemWindow.height,0,0,8,1,0,4,0,6,24,ItemWindowToggleImage,_newspaperDefs.getCoreArray(),"",0,{
            "mouseDown":onIconDown,
            "mouseOver":null,
            "mouseOut":null
         },null,onIconWindowsLoaded,true,true,true,true);
         _loadingSpiralIcon.destroy();
         _loadingSpiralIcon = null;
         _iconsItemWindow.addChild(_iconWindows);
         if(_newspaperDefs.length <= 8)
         {
            _arrowLBtn.activateGrayState(true);
            _arrowRBtn.activateGrayState(true);
         }
         else
         {
            _arrowLBtn.activateGrayState(false);
            _arrowRBtn.activateGrayState(false);
         }
         AchievementXtCommManager.requestSetUserVar(455,Utility.getCurrEpochTime());
      }
      
      private function onIconWindowsLoaded() : void
      {
         loadPage(0,true);
      }
      
      private function loadPage(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:ItemWindowToggleImage = null;
         var _loc3_:NewspaperDef = null;
         _loadingSpiralPaper.visible = true;
         if(_currSelectedPage != param1 || param2)
         {
            if(!param2)
            {
               _loc4_ = ItemWindowToggleImage(_iconWindows.mediaWindows[_currSelectedPage]);
               _loc4_.downToUpdate();
               _loc4_.window.newBurst.visible = false;
            }
            _currSelectedPage = param1;
            _loc3_ = _newspaperDefs.getNewspaperDefItem(param1);
            _loc4_ = ItemWindowToggleImage(_iconWindows.mediaWindows[_currSelectedPage]);
            if(_loc4_.window.newBurst.visible)
            {
               NewspaperXtCommManager.sendSetPageSeenRequest(_loc3_.defId);
            }
            SBTracker.trackPageview("/game/play/popup/newspaper/#page" + _loc3_.name);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_loc3_.paperMediaId,onPageLoaded);
         }
      }
      
      private function onPageLoaded(param1:MovieClip) : void
      {
         _loadingSpiralPaper.visible = false;
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         while(_paperItemWindow.numChildren > 2)
         {
            _paperItemWindow.removeChildAt(_paperItemWindow.numChildren - 1);
         }
         checkPageForButtons(param1);
         _paperItemWindow.addChild(param1);
      }
      
      private function checkPageForButtons(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Object = null;
         var _loc9_:Array = null;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Object = null;
         if(param1)
         {
            _loc4_ = param1.numChildren;
            _loc5_ = 0;
            while(_loc5_ < param1.numChildren)
            {
               _loc2_ = param1.getChildAt(_loc5_);
               if(_loc2_ != null)
               {
                  _loc9_ = [];
                  _loc7_ = 0;
                  _loc6_ = 0;
                  while(_loc6_ < _loc2_.numChildren)
                  {
                     _loc8_ = _loc2_.getChildAt(_loc6_);
                     if(_loc8_.name.indexOf("movie") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onMovieDown,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("linkTo") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onLinkToBtn,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("joinRoom") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onJoinRoomBtn,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("joinParty") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onJoinPartyBtn,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("imgPoll") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onImgPoll,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("loadPopup") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onLoadPopup,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("gameBtn") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onGameBtn,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("petBtn") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onPetBtn,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("expandTxt") == 0)
                     {
                        _loc8_.addEventListener("rollOver",onExpandRollOverOut,false,0,true);
                        _loc8_.addEventListener("rollOut",onExpandRollOverOut,false,0,true);
                     }
                     else if(_loc8_.name.indexOf("feedback") == 0)
                     {
                        _loc8_.addEventListener("mouseDown",onFeedbackBtn,false,0,true);
                     }
                     _loc6_++;
                  }
               }
               _loc5_++;
            }
         }
      }
      
      private function onMovieDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         var _loc5_:Array = [];
         _loc5_ = param1.currentTarget.name.split("_");
         var _loc3_:int = int(_loc5_[1]);
         var _loc6_:Boolean = _loc5_.length >= 3 ? _loc5_[2] == true : false;
         var _loc2_:String = _loc5_.length >= 4 ? _loc5_[3] : null;
         var _loc4_:int = int(_loc5_.length >= 5 ? _loc5_[4] : null);
         var _loc7_:int = int(_loc5_.length >= 6 ? _loc5_[5] : null);
         GenericListGuiManager.genericListVolumeClicked(_loc3_,{
            "shouldRepeat":_loc6_,
            "msg":_loc2_,
            "width":_loc4_,
            "height":_loc7_
         });
      }
      
      private function onLinkToBtn(param1:MouseEvent) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc2_:URLRequest = null;
         param1.stopPropagation();
         var _loc3_:String = "";
         var _loc4_:Boolean = false;
         if(param1.currentTarget.hasOwnProperty("urlCont"))
         {
            _loc3_ = param1.currentTarget.urlCont.txt.text;
            _loc4_ = true;
         }
         else
         {
            _loc5_ = param1.currentTarget.name.split("_");
            _loc6_ = _loc5_[1];
            if(_loc6_ == "blog")
            {
               if(_loc5_.length > 2)
               {
                  _loc3_ = "http://dailyexplorer.animaljam.com/" + _loc5_[2].split("$").join("-");
               }
               else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
               {
                  _loc3_ = "http://dailyexplorer.animaljam.com/pt";
               }
               else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
               {
                  _loc3_ = "http://dailyexplorer.animaljam.com/es";
               }
               else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
               {
                  _loc3_ = "http://dailyexplorer.animaljam.com/fr";
               }
               else
               {
                  _loc3_ = "http://dailyexplorer.animaljam.com/";
               }
            }
            else if(_loc6_ == "outfitters")
            {
               _loc3_ = "http://shop.animaljam.com/";
               if(_loc5_[2])
               {
                  _loc3_ += _loc5_[2].split("$").join("/");
               }
            }
            else if(_loc6_ == "jump")
            {
               _loc3_ = "http://jump.animaljam.com/";
            }
            else if(_loc6_ == "academy")
            {
               _loc3_ = "http://academy.animaljam.com/";
            }
            else if(_loc6_ == "blogCat")
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/?cat=" + _loc5_[2];
            }
         }
         if(_loc3_ != "")
         {
            if(_loc4_)
            {
               _externalLinkPopup = new ExternalLinkPopup(_loc3_,onChooseExternalLink);
               return;
            }
            _loc2_ = new URLRequest(_loc3_);
            try
            {
               navigateToURL(_loc2_,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
      }
      
      private function onChooseExternalLink(param1:Boolean, param2:String) : void
      {
         var _loc3_:URLRequest = null;
         if(param1)
         {
            _loc3_ = new URLRequest(param2);
            try
            {
               navigateToURL(_loc3_,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
         _externalLinkPopup.destroy();
         _externalLinkPopup = null;
      }
      
      private function onJoinRoomBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Array = param1.currentTarget.name.replace("joinRoom_","").split("$")[0].split("_");
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14775,LocalizationManager.translateIdOnly(_loc2_[0])),true,onConfirmJoinRoom,param1.currentTarget.name);
      }
      
      private function onConfirmJoinRoom(param1:Object) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc2_:Array = null;
         if(param1.status)
         {
            _loc3_ = param1.passback.split("$");
            _loc3_.shift();
            _loc4_ = _loc3_.join("$");
            _loc4_ = _loc4_.replace("$",".");
            _loc2_ = _loc4_.split("$");
            _loc4_ = _loc2_[0];
            _loc4_ = _loc4_.toLowerCase() + "#" + RoomManagerWorld.instance.shardId;
            if(_loc4_ != gMainFrame.server.getCurrentRoomName())
            {
               if(_loc2_.length == 2)
               {
                  RoomManagerWorld.instance.setGotoSpawnPoint(_loc2_[1].toLowerCase());
               }
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager.sendRoomJoinRequest(_loc4_);
            }
         }
      }
      
      private function onJoinPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.name.split("_")[1]);
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14776,LocalizationManager.translateIdOnly(PartyManager.getPartyDef(_loc2_).titleStrId)),true,onConfirmJoinParty,_loc2_);
      }
      
      private function onConfirmJoinParty(param1:Object) : void
      {
         if(param1.status)
         {
            gMainFrame.server.setXtObject_Str("sj",[param1.passback]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onImgPoll(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Array = param1.currentTarget.name.split("_");
         ImagePoll.displayPoll(_loc2_[1],_loc2_[2],2926,0,3,1);
      }
      
      private function onLoadPopup(param1:MouseEvent) : void
      {
         var _loc2_:MediaHelper = null;
         param1.stopPropagation();
         var _loc3_:Array = param1.currentTarget.name.split("_");
         if(isNaN(_loc3_[1]))
         {
            GuiManager[_loc3_[1]]();
         }
         else if(!_genericPopup)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = new MediaHelper();
            _loc2_.init(_loc3_[1],onPopupLoaded);
         }
         else
         {
            GuiManager.guiLayer.addChild(_genericPopup);
            DarkenManager.darken(_genericPopup);
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _genericPopup = MovieClip(param1.getChildAt(0));
            _genericPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _genericPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
            GuiManager.guiLayer.addChild(_genericPopup);
            _genericPopup.x = 900 * 0.5;
            _genericPopup.y = 550 * 0.5;
            DarkenManager.darken(_genericPopup);
         }
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.guiLayer.removeChild(_genericPopup);
         DarkenManager.unDarken(_genericPopup);
      }
      
      private function onGameBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _gameLaunchObj = {"typeDefId":param1.currentTarget.name.split("_")[1]};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(_gameLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([_gameLaunchObj.typeDefId],false,onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(_gameLaunchObj,null,true);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_gameLaunchObj,null,true);
      }
      
      private function onPetBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         PetManager.openPetFinder(PetManager.petNameForDefId(param1.currentTarget.name.split("_")[1]),null,false,null,null,0,0,true);
      }
      
      private function onExpandRollOverOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.type == "rollOut")
         {
            param1.currentTarget.gotoAndPlay("off");
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
         }
      }
      
      private function onFeedbackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FeedbackManager.openFeedbackPopup(param1.currentTarget.name.split("_")[1]);
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _arrowLBtn.addEventListener("mouseDown",scrollBtnHandler,false,0,true);
         _arrowRBtn.addEventListener("mouseDown",scrollBtnHandler,false,0,true);
         _pageMouseOver.addEventListener("mouseOver",onPaperOver,false,0,true);
         _pageMouseOver.addEventListener("mouseOut",onPaperOut,false,0,true);
         _leftBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         _rightBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         gMainFrame.stage.addEventListener("keyDown",onKeyDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _bx.removeEventListener("mouseDown",onCloseBtn);
         _arrowLBtn.removeEventListener("mouseDown",scrollBtnHandler);
         _arrowRBtn.removeEventListener("mouseDown",scrollBtnHandler);
         _pageMouseOver.removeEventListener("mouseOver",onPaperOver);
         _pageMouseOver.removeEventListener("mouseOut",onPaperOut);
         _leftBtn.removeEventListener("mouseDown",onLeftRight);
         _rightBtn.removeEventListener("mouseDown",onLeftRight);
         gMainFrame.stage.removeEventListener("keyDown",onKeyDown);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPaperOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _popup.page_MouseOver.alpha = 1;
      }
      
      private function onPaperOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _popup.page_MouseOver.alpha = 0;
      }
      
      private function onLeftRight(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:* = false;
         var _loc4_:int = 0;
         param1.stopPropagation();
         if(_newspaperDefs.length > 0)
         {
            _loc5_ = _currSelectedPage;
            _loc3_ = _currSelectedPage;
            if(param1 is KeyboardEvent)
            {
               _loc4_ = int((param1 as KeyboardEvent).keyCode);
               if(!(_loc4_ == 39 || _loc4_ == 37 || _loc4_ == 38 || _loc4_ == 40))
               {
                  return;
               }
               _loc2_ = _loc4_ == 37 || _loc4_ == 38;
            }
            else
            {
               _loc2_ = param1.currentTarget == _leftBtn;
            }
            if(_loc2_)
            {
               if(_leftBtn.isGray)
               {
                  return;
               }
               if(_loc3_ - 1 >= 0)
               {
                  _loc3_--;
               }
            }
            else
            {
               if(_rightBtn.isGray)
               {
                  return;
               }
               if(_loc3_ + 1 <= _newspaperDefs.length - 1)
               {
                  _loc3_++;
               }
            }
            if(_loc3_ != _loc5_)
            {
               _iconWindows.scrollToIndex(_loc3_,false);
               ItemWindowToggleImage(_iconWindows.mediaWindows[_loc3_]).myMouseDown(null);
            }
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         param1.preventDefault();
         param1.stopPropagation();
         onLeftRight(param1);
      }
      
      private function onIconDown(param1:int) : void
      {
         loadPage(param1);
      }
      
      private function scrollBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            _iconWindows.handleScrollBtnClick(param1.currentTarget.name == _arrowLBtn.name);
         }
      }
   }
}

