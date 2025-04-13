package gui.jazwares
{
   import Enums.AdoptAPetDef;
   import adoptAPet.AdoptAPetData;
   import adoptAPet.AdoptAPetManager;
   import adoptAPet.AdoptAPetXtCommManager;
   import adoptAPet.TierPathPopup;
   import collection.AdoptAPetDataCollection;
   import collection.AdoptAPetDefCollection;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowLargeIcon;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class CheckListPopup
   {
      private const CHECKLIST_MEDIA_ID:int = 4622;
      
      private var _mediaHelper:MediaHelper;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _checkListPopup:MovieClip;
      
      private var _infoBtn:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _itemWindow:MovieClip;
      
      private var _giftBarBtn:MovieClip;
      
      private var _infoPopup:AdoptAPetInfoPopup;
      
      private var _tierPathPopup:TierPathPopup;
      
      private var _checkListWindows:WindowAndScrollbarGenerator;
      
      private var _userName:String;
      
      private var _giftCountTxt:TextField;
      
      private var _counterTxt:TextField;
      
      private var _usableAdoptAPetData:AdoptAPetDataCollection;
      
      private var _tieredUsableAmount:Array;
      
      private var _tieredWindowList:Array;
      
      private var _currSelectedTab:MovieClip;
      
      private var _tabs:Array;
      
      private var _defIdsToUpdate:Array;
      
      public function CheckListPopup()
      {
         super();
      }
      
      public function init(param1:Function, param2:String = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _userName = param2 == null ? gMainFrame.userInfo.myUserName : param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4622,onChecklistMediaLoded);
      }
      
      public function destroy() : void
      {
         var _loc2_:Function = null;
         var _loc1_:Array = null;
         var _loc3_:int = 0;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            _loc2_();
            _loc2_ = null;
            return;
         }
         if(_checkListWindows)
         {
            if(_userName == gMainFrame.userInfo.myUserName)
            {
               _loc1_ = _checkListWindows.mediaWindows;
               if(_defIdsToUpdate == null)
               {
                  _defIdsToUpdate = [];
               }
               while(_loc3_ < _loc1_.length)
               {
                  if((_loc1_[_loc3_] as ItemWindowLargeIcon).defIdSeenUpdated != 0)
                  {
                     if(_defIdsToUpdate.indexOf((_loc1_[_loc3_] as ItemWindowLargeIcon).defIdSeenUpdated) == -1)
                     {
                        _defIdsToUpdate.push((_loc1_[_loc3_] as ItemWindowLargeIcon).defIdSeenUpdated);
                     }
                  }
                  _loc3_++;
               }
            }
            _checkListWindows.destroy();
            _checkListWindows = null;
         }
         if(_defIdsToUpdate && _defIdsToUpdate.length > 0)
         {
            AdoptAPetXtCommManager.requestPetAdoptUsableSeenSet(_defIdsToUpdate);
            _defIdsToUpdate = null;
         }
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         DarkenManager.unDarken(_checkListPopup);
         _guiLayer.removeChild(_checkListPopup);
         _guiLayer = null;
         _checkListPopup = null;
      }
      
      private function onChecklistMediaLoded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         _checkListPopup = param1.getChildAt(0) as MovieClip;
         _checkListPopup.x = 900 * 0.5;
         _checkListPopup.y = 550 * 0.5;
         _guiLayer.addChild(_checkListPopup);
         DarkenManager.darken(_checkListPopup);
         _closeBtn = _checkListPopup.bx;
         _infoBtn = _checkListPopup.infoBtn;
         _itemWindow = _checkListPopup.itemWindow;
         _giftBarBtn = _checkListPopup.giftBarBtn;
         _giftCountTxt = _checkListPopup.giftBarCont.countTxt;
         _giftCountTxt.text = "0/0";
         _counterTxt = _checkListPopup.itemCounter.counterTxt;
         _counterTxt.text = "0/0";
         _checkListPopup.series_1_tab.upToDownState();
         _currSelectedTab = _checkListPopup.series_1_tab;
         _currSelectedTab.originalChildIndex = _checkListPopup.getChildIndex(_currSelectedTab);
         _tabs = [];
         _loc2_ = 1;
         while(_loc2_ <= 7)
         {
            if(_loc2_ < 6)
            {
               _tabs[_loc2_] = _checkListPopup["series_" + _loc2_ + "_tab"];
            }
            else if(_loc2_ == 6)
            {
               _tabs[_loc2_] = _checkListPopup["treasure_" + _loc2_ + "_tab"];
            }
            else if(_loc2_ == 7)
            {
               _tabs[_loc2_] = _checkListPopup["limited_" + _loc2_ + "_tab"];
            }
            if(_tabs[_loc2_])
            {
               _tabs[_loc2_].originalX = _tabs[_loc2_].x;
            }
            _loc2_++;
         }
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         if(_userName == gMainFrame.userInfo.myUserName)
         {
            _usableAdoptAPetData = AdoptAPetManager.usableAdoptAPetDataCopy;
            setupCheckListWindows(true);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            AdoptAPetXtCommManager.requestPetAdoptUsableData(_userName,onOtherUserUsableAdoptAPetData);
         }
      }
      
      private function setupCheckListWindows(param1:Boolean) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:AdoptAPetData = null;
         var _loc5_:int = 0;
         var _loc3_:* = 0;
         var _loc9_:Array = null;
         var _loc10_:AdoptAPetDefCollection = null;
         var _loc4_:AdoptAPetDef = null;
         var _loc11_:AdoptAPetDefCollection = null;
         var _loc6_:AdoptAPetDef = null;
         var _loc12_:int = 0;
         _usableAdoptAPetData.getCoreArray().sortOn("invId",0x10 | 2);
         _tieredWindowList = [];
         _tieredUsableAmount = [];
         if(param1)
         {
            _loc9_ = AdoptAPetManager.allAdoptAPetDefsNonIndexedBySeriesSortedByName.concat();
            _loc8_ = 0;
            while(_loc8_ < _usableAdoptAPetData.length)
            {
               _loc2_ = _usableAdoptAPetData.getAdoptAPetDataItem(_loc8_);
               if(_loc2_)
               {
                  if(_tieredWindowList[_loc2_.series] == null)
                  {
                     _tieredWindowList[_loc2_.series] = [];
                  }
                  _tieredWindowList[_loc2_.series].push(_loc2_);
                  _loc10_ = _loc9_[_loc2_.series];
                  _loc7_ = 0;
                  while(_loc7_ < _loc10_.length)
                  {
                     _loc4_ = _loc10_.getAdoptAPetItem(_loc7_);
                     if(_loc4_ && _loc2_.defId == _loc4_.defId)
                     {
                        _loc10_.getCoreArray().splice(_loc7_,1);
                        break;
                     }
                     _loc7_++;
                  }
               }
               _loc8_++;
            }
            _loc3_ = 1;
            _loc8_ = 1;
            while(_loc8_ <= 7)
            {
               if(_tieredWindowList[_loc8_])
               {
                  _tieredUsableAmount[_loc8_] = _tieredWindowList[_loc8_].length;
                  _loc11_ = _loc9_[_loc8_];
                  _loc7_ = 0;
                  while(_loc7_ < _loc11_.length)
                  {
                     _loc6_ = _loc11_.getAdoptAPetItem(_loc7_);
                     if(!_loc6_.hidden)
                     {
                        _tieredWindowList[_loc8_].push(_loc6_);
                     }
                     _loc7_++;
                  }
               }
               else if((_loc8_ == 1 || _loc8_ == 6 || _loc8_ == 2 || _loc8_ == 3 || _loc8_ == 4) && _loc9_[_loc8_])
               {
                  _tieredWindowList[_loc8_] = [];
                  _loc11_ = _loc9_[_loc8_];
                  _loc7_ = 0;
                  while(_loc7_ < _loc11_.length)
                  {
                     _loc6_ = _loc11_.getAdoptAPetItem(_loc7_);
                     if(!_loc6_.hidden)
                     {
                        _tieredWindowList[_loc8_].push(_loc6_);
                     }
                     _loc7_++;
                  }
               }
               else
               {
                  _tabs[_loc8_].visible = false;
                  _loc7_ = _loc8_ + 1;
                  while(_loc7_ < _tabs.length)
                  {
                     _tabs[_loc7_].x = _tabs[_loc7_ - 1].originalX;
                     _tabs[_loc7_ - 1].originalX = _tabs[_loc7_ - 1].x;
                     _loc7_++;
                  }
               }
               _loc8_++;
            }
            _loc5_ = int(_tieredUsableAmount[1]);
            if(AdoptAPetManager.numTieredGiftCount > AdoptAPetManager.getCurrTierGiftCountAmount())
            {
               _giftCountTxt.text = String(AdoptAPetManager.numTieredGiftCount);
            }
            else
            {
               _giftCountTxt.text = AdoptAPetManager.numTieredGiftCount + "/" + AdoptAPetManager.getCurrTierGiftCountAmount();
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < _usableAdoptAPetData.length)
            {
               _loc2_ = _usableAdoptAPetData.getAdoptAPetDataItem(_loc8_);
               if(_loc2_)
               {
                  if(_tieredWindowList[_loc2_.series] == null)
                  {
                     _tieredWindowList[_loc2_.series] = [];
                  }
                  _tieredWindowList[_loc2_.series].push(_loc2_);
               }
               _loc8_++;
            }
            _loc8_ = 1;
            while(_loc8_ <= 7)
            {
               if(_tieredWindowList[_loc8_])
               {
                  _loc12_ += _tieredWindowList[_loc8_].length;
                  if(_loc3_ == 0)
                  {
                     _loc3_ = _loc8_;
                  }
               }
               else
               {
                  _tabs[_loc8_].visible = false;
                  _loc7_ = _loc8_ + 1;
                  while(_loc7_ < _tabs.length)
                  {
                     _tabs[_loc7_].x = _tabs[_loc7_ - 1].originalX;
                     _tabs[_loc7_ - 1].originalX = _tabs[_loc7_ - 1].x;
                     _loc7_++;
                  }
               }
               _loc8_++;
            }
            _loc5_ = int(_tieredWindowList[_loc3_].length);
            if(_loc12_ > AdoptAPetManager.getCurrTierGiftCountAmount(_loc12_))
            {
               _giftCountTxt.text = String(_loc12_);
            }
            else
            {
               _giftCountTxt.text = _loc12_ + "/" + AdoptAPetManager.getCurrTierGiftCountAmount(_loc12_);
            }
         }
         _counterTxt.text = _loc5_ + "/" + _tieredWindowList[_loc3_].length;
         _checkListWindows = new WindowAndScrollbarGenerator();
         _checkListWindows.init(_itemWindow.width,_itemWindow.height,9,0,6,4,0,-3,0,5,2,ItemWindowLargeIcon,_tieredWindowList[_loc3_],"",0,null,{"isForMyself":param1},null,true,false,false);
         _itemWindow.addChild(_checkListWindows);
      }
      
      private function updateListWindows(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc3_:int = 0;
         if(_checkListWindows)
         {
            if(_userName == gMainFrame.userInfo.myUserName)
            {
               _loc2_ = _checkListWindows.mediaWindows;
               if(_defIdsToUpdate == null)
               {
                  _defIdsToUpdate = [];
               }
               while(_loc4_ < _loc2_.length)
               {
                  if((_loc2_[_loc4_] as ItemWindowLargeIcon).defIdSeenUpdated != 0)
                  {
                     _defIdsToUpdate.push((_loc2_[_loc4_] as ItemWindowLargeIcon).defIdSeenUpdated);
                  }
                  _loc4_++;
               }
            }
            _itemWindow.removeChild(_checkListWindows);
            _checkListWindows.destroy();
         }
         if(_userName == gMainFrame.userInfo.myUserName)
         {
            _loc5_ = true;
            _loc3_ = int(_tieredUsableAmount[param1]);
         }
         else
         {
            _loc3_ = int(_tieredWindowList[param1].length);
         }
         _checkListWindows = new WindowAndScrollbarGenerator();
         _checkListWindows.init(_itemWindow.width,_itemWindow.height,9,0,6,4,0,-3,0,5,2,ItemWindowLargeIcon,_tieredWindowList[param1],"",0,null,{"isForMyself":_loc5_},null,true,false,false);
         _counterTxt.text = _loc3_ + "/" + (!!_tieredWindowList[param1] ? _tieredWindowList[param1].length : 0);
         _itemWindow.addChild(_checkListWindows);
      }
      
      private function addEventListeners() : void
      {
         _checkListPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _infoBtn.addEventListener("mouseDown",onInfoBtn,false,0,true);
         _giftBarBtn.addEventListener("mouseDown",onGiftBarBtn,false,0,true);
         _checkListPopup.series_1_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.series_2_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.series_3_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.series_4_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.series_5_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.treasure_6_tab.addEventListener("mouseDown",onTabDown,false,0,true);
         _checkListPopup.limited_7_tab.addEventListener("mouseDown",onTabDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _checkListPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
         _infoBtn.removeEventListener("mouseDown",onInfoBtn);
         _giftBarBtn.removeEventListener("mouseDown",onGiftBarBtn);
         _checkListPopup.series_1_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.series_2_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.series_3_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.series_4_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.series_5_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.treasure_6_tab.removeEventListener("mouseDown",onTabDown);
         _checkListPopup.limited_7_tab.removeEventListener("mouseDown",onTabDown);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_infoPopup)
         {
            onInfoPopupClose();
         }
         _infoPopup = new AdoptAPetInfoPopup();
         _infoPopup.init(onInfoPopupClose);
      }
      
      private function onGiftBarBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _tierPathPopup = new TierPathPopup(onTierPopupClose);
      }
      
      private function onTierPopupClose() : void
      {
         _tierPathPopup.destroy();
         _tierPathPopup = null;
      }
      
      private function onTabDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currSelectedTab)
         {
            if(_currSelectedTab == param1.currentTarget)
            {
               _currSelectedTab.upToDownState();
               return;
            }
            _currSelectedTab.downToUpState();
            _checkListPopup.setChildIndex(_currSelectedTab,_currSelectedTab.originalChildIndex);
         }
         _currSelectedTab = param1.currentTarget as MovieClip;
         _currSelectedTab.originalChildIndex = _checkListPopup.getChildIndex(_currSelectedTab);
         _checkListPopup.setChildIndex(_currSelectedTab,_checkListPopup.getChildIndex(_checkListPopup.series_1_tab));
         updateListWindows(param1.currentTarget.name.split("_")[1]);
      }
      
      private function onInfoPopupClose() : void
      {
         _infoPopup.destroy();
         _infoPopup = null;
      }
      
      private function onOtherUserUsableAdoptAPetData(param1:Boolean, param2:Object) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _usableAdoptAPetData = new AdoptAPetDataCollection();
            _loc7_ = int(param2[3]);
            _loc4_ = 4;
            _loc6_ = 0;
            while(_loc6_ < _loc7_)
            {
               _loc3_ = int(param2[_loc4_++]);
               _loc5_ = int(param2[_loc4_++]);
               _usableAdoptAPetData.setAdoptAPetDataItem(_loc3_,new AdoptAPetData(AdoptAPetData.defaultAdoptAPetData(_loc3_,_loc5_)));
               _loc6_++;
            }
            setupCheckListWindows(false);
         }
         else
         {
            destroy();
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(11149));
         }
      }
   }
}

