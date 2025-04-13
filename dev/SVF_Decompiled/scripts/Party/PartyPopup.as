package Party
{
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.greensock.TimelineLite;
   import com.greensock.TweenLite;
   import com.greensock.easing.Expo;
   import com.sbi.popup.SBOkPopup;
   import customParty.CustomPartyCreatePopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowParty;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PartyPopup
   {
      protected const PARTY_POPUP_MEDIA_ID:int = 1215;
      
      protected const REQUEST_INTERVAL:Number = 10000;
      
      protected const ADDITIONAL_ADVENTURE_SCRIPT_ID:int = 283;
      
      protected var _mediaHelper:MediaHelper;
      
      protected var _partyPopup:MovieClip;
      
      protected var _closeCallback:Function;
      
      protected var _customPartiesLoadingSpiral:LoadingSpiral;
      
      protected var _ajPartiesLoadingSpiral:LoadingSpiral;
      
      protected var _ajPartySingleLoadingSpiral:LoadingSpiral;
      
      protected var _headersLoadingSpiral:LoadingSpiral;
      
      protected var _partyDefIds:Array;
      
      protected var _secToStart:Array;
      
      protected var _additionalScriptDefs:Array;
      
      protected var _additionalHeaderData:Array;
      
      protected var _partyMediaIds:Array;
      
      protected var _secToEnd:Array;
      
      protected var _partyDefs:Object;
      
      protected var _mins:Array;
      
      protected var _hours:Array;
      
      protected var _customPartyData:Array;
      
      protected var _adventureHeaderWindow:ItemWindowParty;
      
      protected var _additionalHeaderWindow1:ItemWindowParty;
      
      protected var _additionalHeaderWindow2:ItemWindowParty;
      
      protected var _ajItemWindows:WindowAndScrollbarGenerator;
      
      protected var _ajItemWindowSingle:ItemWindowParty;
      
      protected var _customPartyItemWindows:WindowAndScrollbarGenerator;
      
      protected var _adventureHeaderMediaId:int;
      
      protected var _timeOffset:int;
      
      protected var _initialTime:int;
      
      protected var _numSecPassed:int;
      
      protected var _hadReceivedPartyList:Boolean;
      
      protected var _partiesListLoaded:Boolean;
      
      protected var _useMinimalist:Boolean;
      
      protected var _tabTimeLine:TimelineLite;
      
      protected var _customPartyCreatePopup:CustomPartyCreatePopup;
      
      public function PartyPopup(param1:Function, param2:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _timeOffset = param2;
         _closeCallback = param1;
         _useMinimalist = Utility.daysSinceCreated() < 1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1215,onPartyPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         _closeCallback = null;
         _hadReceivedPartyList = false;
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_adventureHeaderWindow)
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
         if(_additionalHeaderWindow1)
         {
            _additionalHeaderWindow1.destroy();
            _additionalHeaderWindow1 = null;
         }
         if(_additionalHeaderWindow2)
         {
            _additionalHeaderWindow2.destroy();
            _additionalHeaderWindow2 = null;
         }
         if(_ajItemWindowSingle)
         {
            _ajItemWindowSingle.destroy();
            _ajItemWindowSingle = null;
         }
         if(_ajItemWindows)
         {
            _ajItemWindows.destroy();
            _ajItemWindows = null;
         }
         if(_customPartiesLoadingSpiral)
         {
            _customPartiesLoadingSpiral.destroy();
            _customPartiesLoadingSpiral = null;
         }
         if(_ajPartiesLoadingSpiral)
         {
            _ajPartiesLoadingSpiral.destroy();
            _ajPartiesLoadingSpiral = null;
         }
         if(_ajPartySingleLoadingSpiral)
         {
            _ajPartySingleLoadingSpiral.destroy();
            _ajPartySingleLoadingSpiral = null;
         }
         if(_headersLoadingSpiral)
         {
            _headersLoadingSpiral.destroy();
            _headersLoadingSpiral = null;
         }
         if(_tabTimeLine)
         {
            _tabTimeLine.kill();
            _tabTimeLine = null;
         }
         onCustomPartyCreateClose(param1);
         DarkenManager.unDarken(_partyPopup.parent);
         if(GuiManager.guiLayer.contains(_partyPopup.parent))
         {
            GuiManager.guiLayer.removeChild(_partyPopup.parent);
         }
         _partyPopup = null;
      }
      
      public function showPopup(param1:Boolean) : void
      {
         if(_partyPopup)
         {
            if(_customPartyCreatePopup)
            {
               _customPartyCreatePopup.showPopup(false);
            }
            _partyPopup.parent.visible = param1;
            if(param1)
            {
               DarkenManager.darken(_partyPopup.parent);
            }
            else
            {
               DarkenManager.unDarken(_partyPopup.parent);
            }
         }
      }
      
      public function updateTime(param1:int) : void
      {
         if(_hadReceivedPartyList && param1 - _initialTime >= 10000)
         {
            _initialTime = param1;
            onHeartbeat();
         }
      }
      
      public function partyListResponse(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc9_:Object = null;
         var _loc4_:String = null;
         if(_partyPopup)
         {
            _partyDefIds = [];
            _secToStart = [];
            _secToEnd = [];
            _partyMediaIds = [];
            _additionalHeaderData = [];
            _loc6_ = [];
            _loc3_ = int(param1[3]);
            _loc8_ = 4;
            if(_additionalScriptDefs == null)
            {
               GenericListXtCommManager.requestGenericList(283,OnAddionalAdventureScriptDefLoaded,param1);
               return;
            }
            _adventureHeaderMediaId = 2253;
            _loc2_ = -1;
            if(_loc2_ != -1)
            {
               _additionalHeaderData.push({
                  "isParty":true,
                  "defId":_loc2_,
                  "mediaId":int(_partyDefs[_loc2_].mediaRefId),
                  "secToStart":0,
                  "secToEnd":0,
                  "headerTime":Utility.calculateTime(0)
               });
            }
            if(_additionalScriptDefs.length > 0)
            {
               _loc7_ = 0;
               while(_loc7_ < _additionalScriptDefs.length)
               {
                  _loc9_ = QuestXtCommManager.getScriptDef(_additionalScriptDefs[_loc7_]);
                  if(_loc9_)
                  {
                     _additionalHeaderData.push({
                        "isParty":false,
                        "defId":_loc9_.defId,
                        "mediaId":_loc9_.bannerMediaRefId,
                        "secToStart":0,
                        "secToEnd":0,
                        "headerTime":Utility.calculateTime(0)
                     });
                  }
                  _loc7_++;
               }
            }
            initializePartyPopup();
            _loc4_ = _useMinimalist ? "Sml" : "";
            switch(int(_additionalHeaderData.length))
            {
               case 0:
                  _partyPopup.gotoAndStop("header" + _loc4_);
                  break;
               case 1:
                  _partyPopup.gotoAndStop("twoHeader" + _loc4_);
                  break;
               default:
                  _partyPopup.gotoAndStop("threeHeader" + _loc4_);
            }
            setupCreateJoinButtonText();
            addEventListeners();
            setupLoadingSpirals();
            buildHeaderPartyWindows();
            _loc7_ = 0;
            while(_loc7_ < _loc3_)
            {
               _partyDefIds[_loc7_] = int(param1[_loc8_]);
               if(_partyDefs[int(param1[_loc8_])])
               {
                  _loc5_ = int(_partyDefs[int(param1[_loc8_])].titleStrId);
                  if(!_loc6_[_loc5_])
                  {
                     _loc6_[_loc5_] = true;
                  }
                  _partyMediaIds[_loc7_] = int(_partyDefs[int(param1[_loc8_++])].mediaRefId);
                  _secToStart[_loc7_] = Number(param1[_loc8_++]);
                  if(_secToStart[_loc7_] != 0)
                  {
                     var _loc10_:* = _loc7_;
                     var _loc11_:* = _secToStart[_loc10_] + _timeOffset;
                     _secToStart[_loc10_] = _loc11_;
                  }
                  _secToEnd[_loc7_] = Number(param1[_loc8_++]);
               }
               _loc7_++;
            }
            _loc6_ = null;
            calculateTime();
            _initialTime = getTimer();
            buildAJSinglePartyWindow();
            _hadReceivedPartyList = true;
            if(!_useMinimalist)
            {
               PartyXtCommManager.sendCustomPartyListRequest(0,200);
            }
         }
      }
      
      public function customPartyListResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:Object = null;
         var _loc4_:Array = null;
         _customPartyData = [];
         var _loc9_:int = 2;
         var _loc5_:* = param1[_loc9_++] == "1";
         var _loc3_:int = int(param1[_loc9_++]);
         if(_loc3_ > 0)
         {
            _loc2_ = int(param1[_loc9_++]);
            _loc6_ = int(param1[_loc9_++]);
            _loc10_ = int(param1[_loc9_++]);
            if(_loc10_ > 0)
            {
               _loc8_ = 0;
               while(_loc8_ < _loc10_)
               {
                  _loc7_ = {
                     "creator":param1[_loc9_++],
                     "name":param1[_loc9_++],
                     "nodeId":param1[_loc9_++],
                     "defId":int(param1[_loc9_++]),
                     "timeLeft":Number(param1[_loc9_++])
                  };
                  _loc4_ = _loc7_.name.split("|");
                  _loc7_.name = LocalizationManager.translateIdOnly(_loc4_[0]) + " " + LocalizationManager.translateIdOnly(_loc4_[1]) + " " + LocalizationManager.translateIdOnly(_loc4_[2]);
                  _customPartyData.push(_loc7_);
                  _loc8_++;
               }
            }
         }
         buildCustomPartyWindows();
      }
      
      private function onPartyPopupLoaded(param1:MovieClip) : void
      {
         _partyPopup = (param1.getChildAt(0) as MovieClip).partyFrames;
         _mins = [];
         _hours = [];
         requestData();
      }
      
      protected function initializePartyPopup() : void
      {
         if(!GuiManager.guiLayer.contains(_partyPopup.parent))
         {
            DarkenManager.showLoadingSpiral(false);
            _partyPopup.parent.x = 900 * 0.5;
            _partyPopup.parent.y = 550 * 0.5;
            GuiManager.guiLayer.addChild(_partyPopup.parent);
            DarkenManager.darken(_partyPopup.parent);
         }
      }
      
      protected function requestData() : void
      {
         if(PartyManager.partyDefs != null)
         {
            _partyDefs = PartyManager.partyDefs;
            PartyXtCommManager.sendPartyListRequest();
         }
         else
         {
            PartyManager.requestPartyDefs(requestData);
         }
      }
      
      protected function setupLoadingSpirals() : void
      {
         if(_partyPopup.itemWindowSpiral)
         {
            _headersLoadingSpiral = new LoadingSpiral(_partyPopup.itemWindowSpiral,_partyPopup.itemWindowSpiral.width * 0.5,_partyPopup.itemWindowSpiral.height * 0.5);
         }
         if(!_useMinimalist)
         {
            _customPartiesLoadingSpiral = new LoadingSpiral(_partyPopup.itemWindow,_partyPopup.itemWindow.width * 0.5,_partyPopup.itemWindow.height * 0.5);
            _ajPartiesLoadingSpiral = new LoadingSpiral(_partyPopup.frameDrawerCont.itemWindow,_partyPopup.frameDrawerCont.itemWindow.width * 0.5,_partyPopup.frameDrawerCont.itemWindow.height * 0.5);
         }
         _ajPartySingleLoadingSpiral = new LoadingSpiral(_partyPopup.itemWindowAJ,_partyPopup.itemWindowAJ.width * 0.5,_partyPopup.itemWindowAJ.height * 0.5);
      }
      
      protected function buildAJSinglePartyWindow() : void
      {
         if(_ajItemWindowSingle)
         {
            _ajItemWindowSingle.destroy();
         }
         _ajItemWindowSingle = new ItemWindowParty(onSinglePartyWindowLoaded,_partyDefIds[0],"",0,ajWinMouseDown,null,null,null,{
            "mediaRefId":_partyMediaIds,
            "printTimeFunc":getAJWindowPrintTime
         });
      }
      
      private function buildAJPartyWindows() : void
      {
         if(_ajItemWindows)
         {
            _ajItemWindows.destroy();
         }
         _ajItemWindows = new WindowAndScrollbarGenerator();
         _ajItemWindows.init(_partyPopup.frameDrawerCont.itemWindow.width,_partyPopup.frameDrawerCont.itemWindow.height,3,0,1,6,0,0,2,0,1,ItemWindowParty,_partyDefIds,"",0,{"mouseDown":ajWinMouseDown},{
            "mediaRefId":_partyMediaIds,
            "printTimeFunc":getAJWindowPrintTime
         },onAjPartiesLoaded,true,false,false);
      }
      
      private function buildCustomPartyWindows() : void
      {
         if(_customPartyItemWindows)
         {
            _customPartyItemWindows.destroy();
         }
         _customPartyItemWindows = new WindowAndScrollbarGenerator();
         _customPartyItemWindows.init(_partyPopup.itemWindow.width,_partyPopup.itemWindow.height,4,0,1,4,0,0,2,0,1,ItemWindowParty,_customPartyData,"",0,{"mouseDown":customWinMouseDown},{"printTimeFunc":getCustomWindowPrintTime},onCustomPartiesLoaded,true,false,false);
      }
      
      protected function buildHeaderPartyWindows() : void
      {
         if(_adventureHeaderWindow)
         {
            _adventureHeaderWindow.destroy();
            _adventureHeaderWindow = null;
         }
         _adventureHeaderWindow = new ItemWindowParty(onSinglePartyWindowLoaded,null,"",0,singleWinMouseDown,null,null,null,{"mediaRefId":[_adventureHeaderMediaId]});
         if(_additionalHeaderData.length > 0)
         {
            if(_additionalHeaderWindow1)
            {
               _additionalHeaderWindow1.destroy();
               _additionalHeaderWindow1 = null;
            }
            _additionalHeaderWindow1 = new ItemWindowParty(onSinglePartyWindowLoaded,null,"",0,singleWinMouseDown,null,null,null,{
               "mediaRefId":[_additionalHeaderData[0].mediaId],
               "additionalIndex":0
            });
            if(_additionalHeaderData.length == 2)
            {
               if(_additionalHeaderWindow2)
               {
                  _additionalHeaderWindow2.destroy();
                  _additionalHeaderWindow2 = null;
               }
               _additionalHeaderWindow2 = new ItemWindowParty(onSinglePartyWindowLoaded,null,"",0,singleWinMouseDown,null,null,null,{
                  "mediaRefId":[_additionalHeaderData[1].mediaId],
                  "additionalIndex":1
               });
            }
         }
      }
      
      private function calculatePrintTime(param1:int, param2:Boolean = false) : String
      {
         return Utility.calculatePrintTime(_mins[param1],_hours[param1],param2);
      }
      
      protected function calculateTime() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _secToStart.length)
         {
            _loc2_ = Utility.calculateTime(_secToStart[_loc1_]);
            _mins[_loc1_] = _loc2_.mins;
            _hours[_loc1_] = _loc2_.hours;
            _loc1_++;
         }
      }
      
      private function rebuildList() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         _partyMediaIds = [];
         _loc3_ = 0;
         while(_loc3_ < _partyDefIds.length)
         {
            _loc1_ = int(_partyDefs[_partyDefIds[_loc3_]].titleStrId);
            if(!_loc2_[_loc1_])
            {
               _loc2_[_loc1_] = true;
            }
            _partyMediaIds[_loc3_] = int(_partyDefs[_partyDefIds[_loc3_]].mediaRefId);
            _loc3_++;
         }
         if(!_useMinimalist)
         {
            buildAJPartyWindows();
         }
      }
      
      private function getAJWindowPrintTime(param1:int) : String
      {
         return _secToStart[param1] > 0 ? calculatePrintTime(param1) : "";
      }
      
      private function getCustomWindowPrintTime(param1:int) : String
      {
         return Utility.calculatePrintTimeForCustomParties(param1);
      }
      
      protected function addEventListeners() : void
      {
         _partyPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _partyPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         if(!_useMinimalist)
         {
            _partyPopup.frameDrawerCont.ajhqPartyTab_btn.addEventListener("mouseDown",onOpenPartyTab,false,0,true);
            _partyPopup.frameDrawerCont.backTab_btn.addEventListener("mouseDown",onClosePartyTab,false,0,true);
            _partyPopup.throwParty_btn.addEventListener("mouseDown",onThrowPartyBtn,false,0,true);
            _partyPopup.goToParty_btn.addEventListener("mouseDown",onHostPartyBtn,false,0,true);
         }
      }
      
      protected function removeEventListeners() : void
      {
         _partyPopup.removeEventListener("mouseDown",onPopup);
         _partyPopup.bx.removeEventListener("mouseDown",onCloseBtn);
         if(!_useMinimalist)
         {
            _partyPopup.frameDrawerCont.ajhqPartyTab_btn.removeEventListener("mouseDown",onOpenPartyTab);
            _partyPopup.frameDrawerCont.backTab_btn.removeEventListener("mouseDown",onClosePartyTab);
            _partyPopup.throwParty_btn.removeEventListener("mouseDown",onThrowPartyBtn);
            _partyPopup.goToParty_btn.removeEventListener("mouseDown",onHostPartyBtn);
         }
      }
      
      protected function setupCreateJoinButtonText() : void
      {
         var _loc1_:UserInfo = null;
         if(!_useMinimalist)
         {
            _loc1_ = gMainFrame.userInfo.playerUserInfo;
            if(_loc1_)
            {
               if(_loc1_.isStillHosting)
               {
                  _partyPopup.goToParty_btn.visible = true;
                  _partyPopup.throwParty_btn.visible = false;
               }
               else
               {
                  _partyPopup.goToParty_btn.visible = false;
                  _partyPopup.throwParty_btn.visible = true;
               }
            }
         }
      }
      
      protected function OnAddionalAdventureScriptDefLoaded(param1:int, param2:Array, param3:Object) : void
      {
         _additionalScriptDefs = param2;
         partyListResponse(param3);
      }
      
      private function onSinglePartyWindowLoaded(param1:ItemWindowParty, param2:int = -1) : void
      {
         var _loc3_:Object = null;
         if(param1 == _adventureHeaderWindow)
         {
            param1.setupTextAndAnims("");
            _partyPopup.itemWindowHeader.addChild(param1);
         }
         else
         {
            if(param1 == _ajItemWindowSingle)
            {
               _ajPartySingleLoadingSpiral.visible = false;
               (_ajItemWindowSingle.txt.timeTxt as TextField).gridFitType = "subpixel";
               (_ajItemWindowSingle.txt.titleTxtCont.titleTxt as TextField).gridFitType = "subpixel";
               _partyPopup.itemWindowAJ.addChild(param1);
               return;
            }
            _loc3_ = param1 == _additionalHeaderWindow1 ? _additionalHeaderData[0] : _additionalHeaderData[1];
            param1.defId = _loc3_.defId;
            param1.setupTextAndAnims(_loc3_.secToStart > 0 ? Utility.calculatePrintTime(_loc3_.headerTime.mins,_loc3_.headerTime.hours) : "");
            if(_loc3_.isParty)
            {
               param1.titleText = _partyDefs[_loc3_.defId].titleStrId;
            }
            if(param1 == _additionalHeaderWindow1)
            {
               _partyPopup.itemWindowHeader2.addChild(param1);
            }
            else if(param1 == _additionalHeaderWindow2)
            {
               _partyPopup.itemWindowHeader3.addChild(param1);
            }
         }
         if(_additionalHeaderData.length == 2)
         {
            if(_additionalHeaderWindow2 && _additionalHeaderWindow2.parent != null && _additionalHeaderWindow1.parent != null && _adventureHeaderWindow.parent != null)
            {
               _headersLoadingSpiral.visible = false;
            }
         }
         else if(_additionalHeaderWindow1 && _additionalHeaderWindow1.parent != null && _adventureHeaderWindow.parent != null)
         {
            _headersLoadingSpiral.visible = false;
         }
      }
      
      private function onAjPartiesLoaded() : void
      {
         _ajPartiesLoadingSpiral.visible = false;
         _partyPopup.frameDrawerCont.itemWindow.addChild(_ajItemWindows);
         _partiesListLoaded = true;
      }
      
      private function onCustomPartiesLoaded() : void
      {
         _customPartiesLoadingSpiral.visible = false;
         _partyPopup.itemWindow.addChild(_customPartyItemWindows);
      }
      
      protected function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick({"typeDefId":102},null,true);
      }
      
      private function onHeartbeat() : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:ItemWindowParty = null;
         var _loc6_:int = 0;
         _numSecPassed += 10;
         _loc4_ = 0;
         while(_loc4_ < _secToStart.length)
         {
            _loc3_ = int(_hours[_loc4_]);
            _loc1_ = int(_mins[_loc4_]);
            if(_loc3_ > 0 || _loc1_ > 0)
            {
               var _loc7_:* = _loc4_;
               var _loc8_:* = _secToStart[_loc7_] - 10;
               _secToStart[_loc7_] = _loc8_;
               if(_secToStart[_loc4_] <= 0)
               {
                  _loc3_ = 0;
                  _loc1_ = 0;
               }
               else if(_numSecPassed == 60)
               {
                  if(_loc3_ > 0 && _loc1_ == 0)
                  {
                     _loc3_--;
                  }
                  if(_loc1_ == 0)
                  {
                     _loc1_ = 59;
                  }
                  else
                  {
                     _loc1_--;
                  }
               }
               _hours[_loc4_] = _loc3_;
               _mins[_loc4_] = _loc1_;
               if(_partiesListLoaded)
               {
                  _loc2_ = ItemWindowParty(_ajItemWindows.mediaWindows[_loc4_]);
                  _loc2_.setupTextAndAnims(_loc3_ > 0 || _loc1_ > 0 ? calculatePrintTime(_loc4_) : "");
               }
               if(_loc4_ == 0)
               {
                  _ajItemWindowSingle.setupTextAndAnims(_loc3_ > 0 || _loc1_ > 0 ? calculatePrintTime(_loc4_) : "");
               }
            }
            else
            {
               _loc8_ = _loc4_;
               _loc7_ = _secToEnd[_loc8_] - 10;
               _secToEnd[_loc8_] = _loc7_;
               if(_secToEnd[_loc4_] <= 0)
               {
                  if(_partiesListLoaded)
                  {
                     _ajItemWindows.deleteItem(_loc4_,_partyDefIds);
                  }
                  else
                  {
                     _partyDefIds.splice(_loc4_,1);
                  }
                  _partyMediaIds.splice(_loc4_,1);
                  _secToStart.splice(_loc4_,1);
                  _secToEnd.splice(_loc4_,1);
                  _hours.splice(_loc4_,1);
                  _mins.splice(_loc4_,1);
                  if(_loc4_ == 0)
                  {
                     _ajItemWindowSingle.destroy();
                     _ajItemWindowSingle = new ItemWindowParty(onSinglePartyWindowLoaded,null,"",0,ajWinMouseDown,null,null,null,{
                        "mediaRefId":_partyMediaIds,
                        "printTimeFunc":getAJWindowPrintTime
                     });
                  }
                  _loc4_--;
               }
            }
            _loc4_++;
         }
         if(_customPartyData)
         {
            _loc4_ = 0;
            while(_loc4_ < _customPartyData.length)
            {
               _customPartyData[_loc4_].timeLeft -= 10;
               _loc6_ = int(_customPartyData[_loc4_].timeLeft);
               if(_loc6_ <= 0)
               {
                  _customPartyItemWindows.deleteItem(_loc4_,_customPartyData);
                  setupCreateJoinButtonText();
               }
               else
               {
                  _loc2_ = ItemWindowParty(_customPartyItemWindows.mediaWindows[_loc4_]);
                  _loc2_.setupTextAndAnims(getCustomWindowPrintTime(_loc6_));
               }
               _loc4_++;
            }
         }
         if(_numSecPassed == 60)
         {
            _numSecPassed = 0;
         }
      }
      
      private function onCustomPartyCreateClose(param1:Boolean = false) : void
      {
         if(_customPartyCreatePopup)
         {
            _customPartyCreatePopup.destroy(param1);
            _customPartyCreatePopup = null;
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      protected function onCloseBtn(param1:MouseEvent) : void
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
      
      private function onOpenPartyTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_tabTimeLine)
         {
            if(_tabTimeLine.reversed())
            {
               _tabTimeLine.reversed(false);
               _tabTimeLine.resume();
            }
            else
            {
               _tabTimeLine.reversed(true);
            }
         }
         else
         {
            _tabTimeLine = new TimelineLite();
            _tabTimeLine.add(new TweenLite(_partyPopup.frameDrawerCont,1,{
               "x":"+=370",
               "ease":Expo.easeInOut
            }),0);
            _tabTimeLine.add(new TweenLite(_partyPopup,1,{
               "x":"-=170",
               "ease":Expo.easeInOut
            }),0);
         }
         if(_ajItemWindows == null && !_useMinimalist)
         {
            buildAJPartyWindows();
         }
      }
      
      private function onClosePartyTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_tabTimeLine.reversed())
         {
            _tabTimeLine.reverse();
         }
      }
      
      private function onThrowPartyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_customPartyCreatePopup)
         {
            _customPartyCreatePopup.destroy();
         }
         _customPartyCreatePopup = new CustomPartyCreatePopup(onCustomPartyCreateClose);
      }
      
      private function onHostPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:UserInfo = gMainFrame.userInfo.playerUserInfo;
         if(_loc3_)
         {
            if(_loc3_.isStillHosting)
            {
               _loc2_ = gMainFrame.server.getCurrentRoomName();
               if(_loc2_.indexOf("pparty") == -1 || _loc2_.indexOf(_loc3_.userName) == -1)
               {
                  PartyManager.sendCustomPartyJoin(_loc3_.userName,_loc3_.uuid,null);
               }
            }
         }
      }
      
      private function singleWinMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(param1.currentTarget == _adventureHeaderWindow)
         {
            DarkenManager.showLoadingSpiral(true);
            if(AvatarManager.roomEnviroType == 1)
            {
               RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_421_0_586#" + RoomManagerWorld.instance.shardId);
            }
            else
            {
               RoomXtCommManager.sendNonDenRoomJoinRequest("adventures.queststaging_421_0_585#" + RoomManagerWorld.instance.shardId);
            }
         }
         else
         {
            _loc2_ = _additionalHeaderData[param1.currentTarget.additionalIndex];
            if(_loc2_)
            {
               if(_loc2_.isParty)
               {
                  if(_loc2_.secToStart <= 0)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
                     onCloseBtn(null);
                  }
                  else
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,Utility.calculatePrintTime(_loc2_.headerTime.mins,_loc2_.headerTime.hours,true)));
                  }
               }
               else
               {
                  DarkenManager.showLoadingSpiral(true);
                  QuestXtCommManager.sendQuestCreateJoinPublic(param1.currentTarget.defId);
                  onCloseBtn(null);
               }
            }
         }
      }
      
      protected function ajWinMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(param1.currentTarget.index);
         if(_secToStart[_loc2_] - _timeOffset <= 0)
         {
            if(_secToEnd[_loc2_] <= (getTimer() - _initialTime) / 1000)
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14777));
               if(_partiesListLoaded)
               {
                  _ajItemWindows.deleteItem(_loc2_,_partyDefIds);
               }
               else
               {
                  _partyDefIds.splice(_loc2_,1);
               }
               _partyMediaIds.splice(_loc2_,1);
               _secToStart.splice(_loc2_,1);
               _secToEnd.splice(_loc2_,1);
               _hours.splice(_loc2_,1);
               _mins.splice(_loc2_,1);
               if(_loc2_ == 0)
               {
                  _ajItemWindowSingle.destroy();
                  _ajItemWindowSingle = new ItemWindowParty(onSinglePartyWindowLoaded,null,"",0,ajWinMouseDown,null,null,null,{
                     "mediaRefId":_partyMediaIds,
                     "printTimeFunc":getAJWindowPrintTime
                  });
               }
               return;
            }
            DarkenManager.showLoadingSpiral(true);
            if(param1.currentTarget.isGame)
            {
               if(MinigameManager.minigameInfoCache.getMinigameInfo(102) == null)
               {
                  MinigameXtCommManager.sendMinigameInfoRequest([102],false,onMinigameInfoResponse);
               }
               else
               {
                  MinigameManager.handleGameClick({"typeDefId":102},null,true);
               }
            }
            else
            {
               PartyXtCommManager.sendJoinPartyRequest(param1.currentTarget.defId);
            }
            onCloseBtn(null);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14778,calculatePrintTime(_loc2_,true)));
         }
      }
      
      private function customWinMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc5_:Object = null;
         var _loc3_:UserInfo = null;
         param1.stopPropagation();
         var _loc4_:int = int(param1.currentTarget.index);
         if(param1.currentTarget.timeLeft <= 0)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14777));
            if(_customPartyItemWindows)
            {
               _customPartyItemWindows.deleteItem(_loc4_,_customPartyData);
            }
            else
            {
               _customPartyData.splice(_loc4_,1);
            }
            setupCreateJoinButtonText();
         }
         else
         {
            _loc2_ = gMainFrame.server.getCurrentRoomName();
            _loc5_ = _customPartyData[_loc4_];
            _loc3_ = gMainFrame.userInfo.playerUserInfo;
            if(_loc2_.indexOf("pparty") == -1 || _loc2_.indexOf(_loc3_.userName) == -1)
            {
               PartyManager.sendCustomPartyJoin("",_loc5_.creator,_loc5_.nodeId);
            }
            else if(_loc3_.uuid != _loc5_.creator)
            {
               PartyManager.sendCustomPartyJoin("",_loc5_.creator,_loc5_.nodeId);
            }
         }
      }
   }
}

