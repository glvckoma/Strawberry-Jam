package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.MinigameInfo;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class GameCardPopup
   {
      private static const LEADERBOARD_TYPE_ALLTIME:int = 1;
      
      private static const LEADERBOARD_TYPE_THISWEEK:int = 2;
      
      private static const LEADERBOARD_TYPE_BUDDY:int = 3;
      
      private static var instrObjs:Object;
      
      private var _onStartClicked:Function;
      
      private var _thePopup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _parent:DisplayObjectContainer;
      
      private var _gameCard:Sprite;
      
      private var _onInstrClicked:Function;
      
      private var _onCloseCallback:Function;
      
      private var _showProModeBtn:Boolean;
      
      private var _proModeValue:Number;
      
      private var _isMultiplayer:Boolean;
      
      private var _originalBX:int;
      
      private var _joinGamePopup:MovieClip;
      
      private var _joinGamePopupTwo:MovieClip;
      
      private var _instructionsPopup:MovieClip;
      
      private var _instructionsPopupTwo:MovieClip;
      
      private var _instrInfo:Object;
      
      private var _numScreens:int;
      
      private var _numScreensTwo:int;
      
      private var _currScreen:int;
      
      private var _currScreenTwo:int;
      
      private var _gameName:String;
      
      private var _leaderBoardCache:Dictionary;
      
      private var _joinGameObj:Object;
      
      private var _showLeaderBoard:Boolean;
      
      private var _useDualPopup:Boolean;
      
      private var _secondMinigameInfo:MinigameInfo;
      
      public function GameCardPopup(param1:DisplayObjectContainer, param2:Object, param3:Function, param4:Function, param5:Boolean = false)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _parent = param1;
         _joinGameObj = param2;
         _gameCard = param2.mi.gameCardScreen;
         _onStartClicked = param3;
         _onCloseCallback = param4;
         var _loc6_:int = int(_joinGameObj.mi.proModeUserVarRefId);
         _showProModeBtn = _loc6_ > 0;
         _proModeValue = gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc6_);
         _isMultiplayer = _joinGameObj.mi.maxPlayers > 1;
         _gameName = _joinGameObj.swfName;
         _showLeaderBoard = false;
         if(instrObjs == null)
         {
            setupInstructions();
         }
         _useDualPopup = param5 && _joinGameObj.typeDefId == 51;
         if(_useDualPopup)
         {
            _secondMinigameInfo = MinigameManager.minigameInfoCache.getMinigameInfo(139);
         }
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_useDualPopup ? 6506 : 3754,onGameCardLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         DarkenManager.unDarken(_thePopup);
         _parent.removeChild(_thePopup);
         _thePopup = null;
      }
      
      private function setupInstructions() : void
      {
         instrObjs = {};
         var _loc1_:Object = instrObjs["Pachinko"] = {};
         _loc1_.name = 11284;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11285;
         _loc1_.instrTxts[1] = 11286;
         _loc1_ = instrObjs["MiniGame_Memory"] = {};
         _loc1_.name = 11287;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11288;
         _loc1_.instrTxts[1] = 11289;
         _loc1_ = instrObjs["MoatMadness"] = {};
         _loc1_.name = 11290;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11291;
         _loc1_.instrTxts[1] = 11292;
         _loc1_ = instrObjs["ParachuteGlider"] = {};
         _loc1_.name = 11293;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11294;
         _loc1_.instrTxts[1] = 11295;
         _loc1_ = instrObjs["QuestParachuteGlider"] = {};
         _loc1_.name = 11293;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11294;
         _loc1_.instrTxts[1] = 11295;
         _loc1_ = instrObjs["Trivia"] = {};
         _loc1_.name = 11299;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11297;
         _loc1_.instrTxts[1] = 11298;
         _loc1_ = instrObjs["PhantomFighter"] = {};
         _loc1_.name = 11300;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11301;
         _loc1_.instrTxts[1] = 11302;
         _loc1_ = instrObjs["SpiderShooter"] = {};
         _loc1_.name = 11303;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11304;
         _loc1_.instrTxts[1] = 11305;
         _loc1_ = instrObjs["RiverRace"] = {};
         _loc1_.name = 11306;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11307;
         _loc1_.instrTxts[1] = 11308;
         _loc1_ = instrObjs["WindRider"] = {};
         _loc1_.name = 11309;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11310;
         _loc1_.instrTxts[1] = 11311;
         _loc1_ = instrObjs["DistanceChallenge"] = {};
         _loc1_.name = 11312;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11313;
         _loc1_.instrTxts[1] = 11314;
         _loc1_ = instrObjs["Twister"] = {};
         _loc1_.name = 11315;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11316;
         _loc1_.instrTxts[1] = 11317;
         _loc1_ = instrObjs["MicroMiraSays"] = {};
         _loc1_.name = 11318;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11319;
         _loc1_.instrTxts[1] = 11320;
         _loc1_ = instrObjs["GemBreaker"] = {};
         _loc1_.name = 11321;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11322;
         _loc1_.instrTxts[1] = 11323;
         _loc1_ = instrObjs["SuperSort"] = {};
         _loc1_.name = 11324;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11325;
         _loc1_.instrTxts[1] = 11326;
         _loc1_ = instrObjs["TowerDefense"] = {};
         _loc1_.name = 11327;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11328;
         _loc1_.instrTxts[1] = 11329;
         _loc1_ = instrObjs["FortSmasher"] = {};
         _loc1_.name = 11330;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11331;
         _loc1_.instrTxts[1] = 11332;
         _loc1_ = instrObjs["PillBugs"] = {};
         _loc1_.name = 11333;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11334;
         _loc1_.instrTxts[1] = 11335;
         _loc1_ = instrObjs["FeedingFrenzy"] = {};
         _loc1_.name = 11336;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11337;
         _loc1_.instrTxts[1] = 11338;
         _loc1_ = instrObjs["PhantomsTreasure"] = {};
         _loc1_.name = 11339;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11340;
         _loc1_.instrTxts[1] = 11341;
         _loc1_ = instrObjs["FashionShow"] = {};
         _loc1_.name = 11342;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11343;
         _loc1_.instrTxts[1] = 11344;
         _loc1_ = instrObjs["Adventure"] = {};
         _loc1_.name = "Adventure";
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = "\nHOW TO PLAY\n\n TBD.";
         _loc1_.instrTxts[1] = "\nHINT!\n\n Just Play!";
         _loc1_ = instrObjs["HorseRace"] = {};
         _loc1_.name = 11348;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11349;
         _loc1_.instrTxts[1] = 11350;
         _loc1_ = instrObjs["FallingPhantoms"] = {};
         _loc1_.name = 11351;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11352;
         _loc1_.instrTxts[1] = 11353;
         _loc1_ = instrObjs["HedgeHog"] = {};
         _loc1_.name = 11354;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11355;
         _loc1_.instrTxts[1] = 11356;
         _loc1_ = instrObjs["DolphinRace"] = {};
         _loc1_.name = 11357;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11358;
         _loc1_.instrTxts[1] = 11359;
         _loc1_ = instrObjs["EagleFlap"] = {};
         _loc1_.name = 15735;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 15740;
         _loc1_.instrTxts[1] = 15741;
         _loc1_ = instrObjs["SpotOn"] = {};
         _loc1_.name = 19654;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 19686;
         _loc1_.instrTxts[1] = 19687;
         _loc1_ = instrObjs["ArtStudioPainting"] = {};
         _loc1_.name = 25289;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 25291;
         _loc1_.instrTxts[1] = 25292;
         _loc1_.startBtnStrId = 25290;
         _loc1_ = instrObjs["TouchPool"] = {};
         _loc1_.name = 27925;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 27926;
         _loc1_.instrTxts[1] = 27927;
         _loc1_ = instrObjs["FastFoodies"] = {};
         _loc1_.name = 29291;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 29279;
         _loc1_.instrTxts[1] = 29280;
         _loc1_ = instrObjs["ArtStudioGridDrawing"] = {};
         _loc1_.name = 29972;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 29975;
         _loc1_.instrTxts[1] = 29976;
         _loc1_.startBtnStrId = 25290;
      }
      
      private function onGameCardLoaded(param1:MovieClip) : void
      {
         _thePopup = MovieClip(param1.getChildAt(0));
         _joinGamePopup = _thePopup.joinGame;
         _joinGamePopupTwo = _thePopup.joinGameTwo;
         _instructionsPopup = _thePopup.instructions;
         _instructionsPopupTwo = _thePopup.instructionsTwo;
         _parent.addChild(_thePopup);
         DarkenManager.darken(_thePopup);
         if(_showProModeBtn)
         {
            _joinGamePopup.gotoAndPlay("pro");
            if(_proModeValue <= 0)
            {
               _joinGamePopup.proStartBtn.activateGrayState(true);
            }
         }
         if(_secondMinigameInfo)
         {
            if(_secondMinigameInfo.proModeUserVarRefId > 0)
            {
               _joinGamePopupTwo.gotoAndPlay("pro");
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(_secondMinigameInfo.proModeUserVarRefId) <= 0)
               {
                  _joinGamePopupTwo.proStartBtn.activateGrayState(true);
               }
            }
         }
         addEventListeners();
         if(_joinGamePopup.msg)
         {
            _joinGamePopup.msg.visible = false;
         }
         if(_joinGamePopupTwo && _joinGamePopupTwo.msg)
         {
            _joinGamePopupTwo.msg.visible = false;
         }
         _instructionsPopup.visible = false;
         if(_instructionsPopupTwo)
         {
            _instructionsPopupTwo.visible = false;
         }
         _joinGamePopup.visible = true;
         if(_joinGamePopupTwo)
         {
            _joinGamePopupTwo.visible = true;
         }
         if(_joinGamePopup.hasOwnProperty("gameTitle") && _gameCard != null)
         {
            _joinGamePopup.gameTitle.addChild(_gameCard);
         }
         if(_joinGamePopupTwo && _joinGamePopupTwo.hasOwnProperty("gameTitle") && _secondMinigameInfo.gameCardScreen != null)
         {
            _joinGamePopupTwo.gameTitle.addChild(_secondMinigameInfo.gameCardScreen);
         }
         if(!Utility.canMultiplayer())
         {
            if(_isMultiplayer)
            {
               _joinGamePopup.startBtn.activateGrayState(true);
               _joinGamePopup.proStartBtn.activateGrayState(true);
            }
            if(_joinGamePopupTwo && _secondMinigameInfo.maxPlayers > 1)
            {
               _joinGamePopupTwo.startBtn.activateGrayState(true);
               _joinGamePopupTwo.proStartBtn.activateGrayState(true);
            }
         }
         _instrInfo = instrObjs[_gameName];
         if(_instrInfo && "startBtnStrId" in _instrInfo)
         {
            (_joinGamePopup.startBtn as GuiSoundBtnSubMenu).setTextInLayer(LocalizationManager.translateIdOnly(_instrInfo.startBtnStrId),"txt");
            if(_joinGamePopup.proStartBtn)
            {
               (_joinGamePopup.proStartBtn as GuiSoundBtnSubMenu).setTextInLayer(LocalizationManager.translateIdOnly(_instrInfo.startBtnStrId),"txt");
            }
         }
         if(_secondMinigameInfo && _secondMinigameInfo.swfName)
         {
            _instrInfo = instrObjs[_secondMinigameInfo.swfName];
            if(_instrInfo && "startBtnStrId" in _instrInfo)
            {
               (_joinGamePopupTwo.startBtn as GuiSoundBtnSubMenu).setTextInLayer(LocalizationManager.translateIdOnly(_instrInfo.startBtnStrId),"txt");
               if(_joinGamePopupTwo.proStartBtn)
               {
                  (_joinGamePopupTwo.proStartBtn as GuiSoundBtnSubMenu).setTextInLayer(LocalizationManager.translateIdOnly(_instrInfo.startBtnStrId),"txt");
               }
            }
         }
         if(_joinGamePopupTwo)
         {
            _joinGamePopup.instrBtn.visible = false;
            _joinGamePopupTwo.instrBtn.visible = false;
         }
         _thePopup.x = 900 * 0.5;
         _thePopup.y = 550 * 0.5;
         _originalBX = _thePopup.bx.y;
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function getVisibleLeaderBoard() : int
      {
         if(_thePopup.leaderboards_popup.thisWeekUp.visible)
         {
            return 2;
         }
         if(_thePopup.leaderboards_popup.allTimeUp.visible)
         {
            return 1;
         }
         return 3;
      }
      
      private function addEventListeners() : void
      {
         _thePopup.addEventListener("mouseDown",onPopup,false,0,true);
         _thePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         if(_joinGamePopup.startBtn)
         {
            _joinGamePopup.startBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
         }
         else if(_joinGamePopup.startPlayBtn)
         {
            _joinGamePopup.startPlayBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
         }
         if(_joinGamePopup.proStartBtn)
         {
            _joinGamePopup.proStartBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
         }
         _joinGamePopup.instrBtn.addEventListener("mouseDown",onInstructionsClicked,false,0,true);
         if(_showLeaderBoard)
         {
            _joinGamePopup.leaderboardsButton.gotoAndStop("active");
            _joinGamePopup.leaderboards_popup.thisWeekDown.addEventListener("mouseDown",thisWeekClicked,false,0,true);
            _joinGamePopup.leaderboards_popup.buddiesDown.addEventListener("mouseDown",buddiesClicked,false,0,true);
            _joinGamePopup.leaderboards_popup.allTimeDown.addEventListener("mouseDown",allTimeClicked,false,0,true);
            _joinGamePopup.leaderboards_popup.bx.addEventListener("mouseDown",leaderBoardBXClicked,false,0,true);
            _joinGamePopup.leaderboardsButton.btn.addEventListener("mouseDown",leaderBoardClicked,false,0,true);
         }
         _instructionsPopup.backBtn.addEventListener("mouseDown",backHandler,false,0,true);
         _instructionsPopup.backToMainBtn.addEventListener("mouseDown",backBtnHandlerOnFirstScreen,false,0,true);
         _instructionsPopup.nextBtn.addEventListener("mouseDown",nextHandler,false,0,true);
         if(_joinGamePopupTwo)
         {
            if(_joinGamePopupTwo.startBtn)
            {
               _joinGamePopupTwo.startBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
            }
            else if(_joinGamePopupTwo.startPlayBtn)
            {
               _joinGamePopupTwo.startPlayBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
            }
            if(_joinGamePopupTwo.proStartBtn)
            {
               _joinGamePopupTwo.proStartBtn.addEventListener("mouseDown",onAnyStartClicked,false,0,true);
            }
            _joinGamePopupTwo.instrBtn.addEventListener("mouseDown",onInstructionsClicked,false,0,true);
            _instructionsPopupTwo.backBtn.addEventListener("mouseDown",backHandler,false,0,true);
            _instructionsPopupTwo.backToMainBtn.addEventListener("mouseDown",backBtnHandlerOnFirstScreen,false,0,true);
            _instructionsPopupTwo.nextBtn.addEventListener("mouseDown",nextHandler,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         _thePopup.removeEventListener("mouseDown",onPopup);
         _thePopup.bx.removeEventListener("mouseDown",onClose);
         if(_joinGamePopup.startBtn)
         {
            _joinGamePopup.startBtn.removeEventListener("mouseDown",onAnyStartClicked);
         }
         else if(_joinGamePopup.startPlayBtn)
         {
            _joinGamePopup.startPlayBtn.removeEventListener("mouseDown",onAnyStartClicked);
         }
         if(_joinGamePopup.proStartBtn)
         {
            _joinGamePopup.proStartBtn.removeEventListener("mouseDown",onAnyStartClicked);
         }
         _joinGamePopup.instrBtn.removeEventListener("mouseDown",onInstructionsClicked);
         if(_showLeaderBoard)
         {
            _joinGamePopup.leaderboards_popup.thisWeekDown.removeEventListener("mouseDown",thisWeekClicked);
            _joinGamePopup.leaderboards_popup.buddiesDown.removeEventListener("mouseDown",buddiesClicked);
            _joinGamePopup.leaderboards_popup.allTimeDown.removeEventListener("mouseDown",allTimeClicked);
            _joinGamePopup.leaderboards_popup.bx.removeEventListener("mouseDown",leaderBoardBXClicked);
            _joinGamePopup.leaderboardsButton.btn.removeEventListener("mouseDown",leaderBoardClicked);
         }
         _instructionsPopup.backBtn.removeEventListener("mouseDown",backHandler);
         _instructionsPopup.backToMainBtn.removeEventListener("mouseDown",backBtnHandlerOnFirstScreen);
         _instructionsPopup.nextBtn.removeEventListener("mouseDown",nextHandler);
         if(_joinGamePopupTwo)
         {
            if(_joinGamePopupTwo.startBtn)
            {
               _joinGamePopupTwo.startBtn.removeEventListener("mouseDown",onAnyStartClicked);
            }
            else if(_joinGamePopupTwo.startPlayBtn)
            {
               _joinGamePopupTwo.startPlayBtn.removeEventListener("mouseDown",onAnyStartClicked);
            }
            if(_joinGamePopupTwo.proStartBtn)
            {
               _joinGamePopupTwo.proStartBtn.removeEventListener("mouseDown",onAnyStartClicked);
            }
            _joinGamePopupTwo.instrBtn.removeEventListener("mouseDown",onInstructionsClicked);
            _instructionsPopupTwo.backBtn.removeEventListener("mouseDown",backHandler);
            _instructionsPopupTwo.backToMainBtn.removeEventListener("mouseDown",backBtnHandlerOnFirstScreen);
            _instructionsPopupTwo.nextBtn.removeEventListener("mouseDown",nextHandler);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_instructionsPopup.visible)
         {
            backBtnHandlerOnFirstScreen(param1);
         }
         else
         {
            MinigameManager.readySelfForQuickMinigame(null,false);
            GuiManager.grayOutHudItemsForPrivateLobby(false);
            if(_onCloseCallback != null)
            {
               _onCloseCallback();
            }
            else
            {
               destroy();
            }
         }
      }
      
      private function thisWeekClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joinGamePopup.leaderboards_popup.thisWeekUp.visible = true;
         _joinGamePopup.leaderboards_popup.allTimeUp.visible = false;
         _joinGamePopup.leaderboards_popup.buddiesUp.visible = false;
         onLeaderBoardSelected();
      }
      
      private function buddiesClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joinGamePopup.leaderboards_popup.thisWeekUp.visible = false;
         _joinGamePopup.leaderboards_popup.allTimeUp.visible = false;
         _joinGamePopup.leaderboards_popup.buddiesUp.visible = true;
         onLeaderBoardSelected();
      }
      
      private function allTimeClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joinGamePopup.leaderboards_popup.thisWeekUp.visible = false;
         _joinGamePopup.leaderboards_popup.allTimeUp.visible = true;
         _joinGamePopup.leaderboards_popup.buddiesUp.visible = false;
         onLeaderBoardSelected();
      }
      
      private function leaderBoardClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joinGamePopup.leaderboardsButton.gotoAndPlay("off");
         _joinGamePopup.gotoAndPlay("normal_l");
         _joinGamePopup.gotoAndPlay("pro_l");
         _thePopup.bx.y = -1000;
         if(_joinGameObj != null && _joinGameObj.typeDefId != -1)
         {
            onLeaderBoardSelected();
         }
      }
      
      private function leaderBoardBXClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _joinGamePopup.leaderboardsButton.gotoAndPlay("on");
         _joinGamePopup.gotoAndPlay("normal_l_close");
         _joinGamePopup.gotoAndPlay("pro_l_close");
         _thePopup.bx.y = _originalBX;
      }
      
      public function onLeaderBoardSelected() : void
      {
         if(_thePopup != null && _joinGameObj != null && _joinGameObj.typeDefId != -1)
         {
            _leaderBoardCache = MinigameManager.getLeaderBoardCache();
            if(_leaderBoardCache[_joinGameObj.typeDefId] != null && getTimer() - _leaderBoardCache[_joinGameObj.typeDefId]._cacheTime < 60000)
            {
               switch(getVisibleLeaderBoard() - 1)
               {
                  case 0:
                     populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._allTime);
                     break;
                  case 1:
                     populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._thisWeek);
                  default:
                     break;
                  case 2:
                     populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._buddy);
               }
            }
            else
            {
               populateLeaderBoard(null);
               DarkenManager.showLoadingSpiral(true);
               MinigameXtCommManager.sendMinigameLeaderboardRequest(_joinGameObj.typeDefId);
            }
         }
      }
      
      private function populateLeaderBoard(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.length > 0)
         {
            if(param1[0]._score != -1)
            {
               _joinGamePopup.leaderboards_popup["p11"].text = param1[0]._name;
               _joinGamePopup.leaderboards_popup["s11"].text = param1[0]._score;
            }
            else
            {
               _joinGamePopup.leaderboards_popup["p11"].text = "";
               _joinGamePopup.leaderboards_popup["s11"].text = "";
            }
            _loc2_ = 1;
            while(_loc2_ < 11)
            {
               if(_loc2_ < param1.length)
               {
                  _joinGamePopup.leaderboards_popup["p" + _loc2_].text = param1[_loc2_]._name;
                  _joinGamePopup.leaderboards_popup["s" + _loc2_].text = param1[_loc2_]._score;
                  if(param1[_loc2_]._name == param1[0]._name)
                  {
                     _joinGamePopup.leaderboards_popup["p" + _loc2_].textColor = 26265;
                     _joinGamePopup.leaderboards_popup["s" + _loc2_].textColor = 26265;
                  }
                  else
                  {
                     _joinGamePopup.leaderboards_popup["p" + _loc2_].textColor = 4137240;
                     _joinGamePopup.leaderboards_popup["s" + _loc2_].textColor = 4137240;
                  }
               }
               else
               {
                  _joinGamePopup.leaderboards_popup["p" + _loc2_].text = "";
                  _joinGamePopup.leaderboards_popup["s" + _loc2_].text = "";
               }
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 1;
            while(_loc2_ <= 11)
            {
               _joinGamePopup.leaderboards_popup["p" + _loc2_].text = "";
               _joinGamePopup.leaderboards_popup["s" + _loc2_].text = "";
               _loc2_++;
            }
         }
      }
      
      private function onAnyStartClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         var _loc2_:Object = null;
         if(_joinGamePopupTwo && param1.currentTarget.parent == _joinGamePopupTwo)
         {
            _loc2_ = _joinGameObj;
            _loc2_.mi = _secondMinigameInfo;
            _loc2_.name = LocalizationManager.translateIdOnly(_secondMinigameInfo.titleStrId);
            _loc2_.swfName = _secondMinigameInfo.swfName;
            _loc2_.isPvp = false;
            _loc2_.typeDefId = _secondMinigameInfo.gameDefId;
         }
         if(param1.currentTarget.name == "startBtn" || param1.currentTarget.name == "startPlayBtn")
         {
            _onStartClicked(0,_loc2_);
         }
         else if(param1.currentTarget.name == "proStartBtn")
         {
            _onStartClicked(1,_loc2_);
         }
      }
      
      private function onInstructionsClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_joinGamePopupTwo && param1.currentTarget.parent == _joinGamePopupTwo)
         {
            _instructionsPopupTwo.visible = true;
            _joinGamePopupTwo.visible = false;
            _instructionsPopupTwo.startBtn.visible = false;
            _instrInfo = instrObjs[_secondMinigameInfo.swfName];
            if(_instrInfo == null)
            {
               throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _secondMinigameInfo.swfName + "\"]!");
            }
            _instrInfo.displayName = _secondMinigameInfo.swfName;
            _numScreensTwo = _instrInfo.instrTxts.length;
            _currScreenTwo = 0;
            updateInstrScreen(_instructionsPopupTwo,_instrInfo,_currScreenTwo,_numScreensTwo);
         }
         else
         {
            _instructionsPopup.visible = true;
            _joinGamePopup.visible = false;
            _instructionsPopup.startBtn.visible = false;
            _instrInfo = instrObjs[_gameName];
            if(_instrInfo == null)
            {
               throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _gameName + "\"]!");
            }
            _instrInfo.displayName = _gameName;
            _numScreens = _instrInfo.instrTxts.length;
            _currScreen = 0;
            updateInstrScreen(_instructionsPopup,_instrInfo,_currScreen,_numScreens);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function backHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_instructionsPopupTwo && param1.currentTarget.parent == _instructionsPopupTwo)
         {
            if(_currScreenTwo > 0)
            {
               --_currScreenTwo;
               _instrInfo = instrObjs[_secondMinigameInfo.swfName];
               if(_instrInfo == null)
               {
                  throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _secondMinigameInfo.swfName + "\"]!");
               }
               _instrInfo.displayName = _secondMinigameInfo.swfName;
               updateInstrScreen(_instructionsPopupTwo,_instrInfo,_currScreenTwo,_numScreensTwo);
            }
         }
         else if(_currScreen > 0)
         {
            --_currScreen;
            _instrInfo = instrObjs[_gameName];
            if(_instrInfo == null)
            {
               throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _gameName + "\"]!");
            }
            _instrInfo.displayName = _gameName;
            updateInstrScreen(_instructionsPopup,_instrInfo,_currScreen,_numScreens);
         }
      }
      
      private function nextHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_instructionsPopupTwo && param1.currentTarget.parent == _instructionsPopupTwo)
         {
            if(_currScreenTwo < _numScreensTwo - 1)
            {
               ++_currScreenTwo;
               _instrInfo = instrObjs[_secondMinigameInfo.swfName];
               if(_instrInfo == null)
               {
                  throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _secondMinigameInfo.swfName + "\"]!");
               }
               _instrInfo.displayName = _secondMinigameInfo.swfName;
               updateInstrScreen(_instructionsPopupTwo,_instrInfo,_currScreenTwo,_numScreensTwo);
            }
         }
         else if(_currScreen < _numScreens - 1)
         {
            ++_currScreen;
            _instrInfo = instrObjs[_gameName];
            if(_instrInfo == null)
            {
               throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + _gameName + "\"]!");
            }
            _instrInfo.displayName = _gameName;
            updateInstrScreen(_instructionsPopup,_instrInfo,_currScreen,_numScreens);
         }
      }
      
      private function backBtnHandlerOnFirstScreen(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_instructionsPopupTwo && param1.currentTarget.parent == _instructionsPopupTwo)
         {
            _instructionsPopupTwo.visible = false;
            _joinGamePopupTwo.visible = true;
         }
         else
         {
            _instructionsPopup.visible = false;
            _joinGamePopup.visible = true;
         }
      }
      
      private function updateInstrScreen(param1:MovieClip, param2:Object, param3:int, param4:int) : void
      {
         var _loc5_:int = 0;
         LocalizationManager.translateId(param1.gameName.gameNameTxt,instrObjs[param2.displayName].name);
         LocalizationManager.translateId(param1.gameInstr.gameInstrTxt,param2.instrTxts[param3]);
         _loc5_ = 0;
         while(_loc5_ < param1.instrImg.numChildren)
         {
            param1.instrImg.getChildAt(_loc5_).visible = false;
            _loc5_++;
         }
         if(param1.instrImg[param2.name + param3])
         {
            param1.instrImg[param2.name + param3].visible = true;
         }
         if(param3 == 0)
         {
            if(param4 > 1)
            {
               param1.nextBtn.visible = true;
               param1.nextTxt.visible = true;
            }
            else
            {
               param1.nextBtn.visible = false;
               param1.nextTxt.visible = false;
            }
            param1.backToMainBtn.visible = true;
            param1.backBtn.visible = false;
         }
         else if(param3 == param4 - 1)
         {
            param1.backBtn.visible = true;
            param1.backTxt.visible = true;
            param1.nextBtn.visible = false;
            param1.nextTxt.visible = false;
            param1.backToMainBtn.visible = false;
         }
         else
         {
            param1.backBtn.visible = true;
            param1.backTxt.visible = true;
            param1.nextBtn.visible = true;
            param1.nextTxt.visible = true;
            param1.backToMainBtn.visible = false;
         }
         param1.page.pageTxt.text = param3 + 1 + " / " + param4;
         param1.nextTxt.visible = false;
         param1.backTxt.visible = false;
      }
   }
}

