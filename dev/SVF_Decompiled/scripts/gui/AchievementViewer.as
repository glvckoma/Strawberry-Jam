package gui
{
   import achievement.Achievement;
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import gui.itemWindows.ItemWindowWithSeparators;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class AchievementViewer
   {
      private var _achievementMediaHelper:MediaHelper;
      
      private var _achievementPopupContent:MovieClip;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _sectionItemWindows:Array;
      
      private var _myAchievementsIndexed:Array;
      
      private var _myAchievements:Array;
      
      private var _allAchievementsIndexed:Object;
      
      private var _xPos:int;
      
      private var _yPos:int;
      
      private var _numAchievementsLastDrawn:int;
      
      private var _hasBeenInited:Boolean;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _parent:MovieClip;
      
      public function AchievementViewer()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:MovieClip, param4:int = -1, param5:Boolean = false) : void
      {
         _myAchievements = [];
         _myAchievementsIndexed = [];
         _xPos = param1;
         _yPos = param2;
         _parent = param3;
         if(!gMainFrame.userInfo.playerUserInfo.achievementsIndexed)
         {
            AchievementXtCommManager.requestAchievements(gMainFrame.userInfo.playerUserInfo.userName,achievementListCallback);
            if(_loadingSpiral)
            {
               _loadingSpiral.visible = true;
            }
         }
         else
         {
            _myAchievementsIndexed = gMainFrame.userInfo.playerUserInfo.achievementsIndexed;
            _myAchievements = gMainFrame.userInfo.playerUserInfo.achievements;
         }
         if(param4 != -1 && _achievementPopupContent == null)
         {
            _achievementMediaHelper = new MediaHelper();
            _achievementMediaHelper.init(param4,mediaHelperCallback,param5);
         }
         else
         {
            _achievementPopupContent.x = 0;
            _achievementPopupContent.y = 0;
         }
         if(_achievementPopupContent)
         {
            open();
            _hasBeenInited = true;
         }
      }
      
      public function destroy() : void
      {
         if(_achievementMediaHelper)
         {
            _achievementMediaHelper.destroy();
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_myAchievementsIndexed)
         {
            _myAchievementsIndexed = null;
         }
         if(_achievementPopupContent)
         {
            removeEventListeners();
            DarkenManager.unDarken(_achievementPopupContent);
            _parent.removeChild(_achievementPopupContent);
            _achievementPopupContent.visible = false;
            _achievementPopupContent = null;
         }
         _hasBeenInited = false;
         _parent.trophy.downToUpState();
      }
      
      public function loadMedia(param1:int, param2:MovieClip) : void
      {
         if(param1 != 0)
         {
            _parent = param2;
            _achievementMediaHelper = new MediaHelper();
            _achievementMediaHelper.init(param1,initMediaCallback);
         }
      }
      
      public function open() : void
      {
         _myAchievementsIndexed = gMainFrame.userInfo.playerUserInfo.achievementsIndexed;
         _myAchievements = gMainFrame.userInfo.playerUserInfo.achievements;
         if(_myAchievements && _numAchievementsLastDrawn < _myAchievements.length)
         {
            createWindows();
            _achievementPopupContent.counterTxt.text = _myAchievements.length;
         }
         _achievementPopupContent.parent.setChildIndex(_achievementPopupContent,_achievementPopupContent.parent.numChildren - 1);
         _achievementPopupContent.visible = true;
         DarkenManager.darken(_achievementPopupContent);
      }
      
      public function close() : void
      {
         _parent.trophy.downToUpState();
         _achievementPopupContent.visible = false;
         DarkenManager.unDarken(_achievementPopupContent);
      }
      
      public function get visible() : Boolean
      {
         if(_achievementPopupContent)
         {
            return _achievementPopupContent.visible;
         }
         return false;
      }
      
      public function get hasBeenInited() : Boolean
      {
         return _hasBeenInited;
      }
      
      private function addAchievementCallback(param1:Array) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _myAchievementsIndexed[_loc2_] = param1[_loc2_].image;
            _loc2_++;
         }
      }
      
      private function initMediaCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            _achievementPopupContent = MovieClip(param1.getChildAt(0));
            _achievementPopupContent.counterTxt.text = "";
            _parent.addChild(_achievementPopupContent);
            addEventListeners();
            _achievementPopupContent.visible = false;
            _loadingSpiral = new LoadingSpiral(_achievementPopupContent.itemBlockAll,_achievementPopupContent.itemBlockAll.width * 0.5,_achievementPopupContent.itemBlockAll.height * 0.5);
            _loadingSpiral.visible = false;
            _achievementMediaHelper.destroy();
            _achievementMediaHelper = null;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            _achievementPopupContent = MovieClip(param1.getChildAt(0));
            _achievementPopupContent.x = 0;
            _achievementPopupContent.y = 0;
            _achievementPopupContent.counterTxt.text = "";
            _parent.addChild(_achievementPopupContent);
            addEventListeners();
            DarkenManager.darken(_achievementPopupContent);
            _loadingSpiral = new LoadingSpiral(_achievementPopupContent.itemBlockAll,_achievementPopupContent.itemBlockAll.width * 0.5,_achievementPopupContent.itemBlockAll.height * 0.5);
            _loadingSpiral.visible = false;
            if(param1.passback)
            {
               _achievementPopupContent.visible = false;
            }
            else
            {
               _achievementPopupContent.counterTxt.text = _myAchievements.length;
               createWindows();
               _hasBeenInited = true;
            }
         }
      }
      
      private function achievementListCallback(param1:Array, param2:Array) : void
      {
         if(param1)
         {
            _myAchievements = param1;
            _myAchievementsIndexed = param2;
            if(_achievementPopupContent)
            {
               _achievementPopupContent.counterTxt.text = _myAchievements.length;
               createWindows(true);
            }
         }
      }
      
      private function createWindows(param1:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc14_:int = 0;
         var _loc3_:int = 0;
         var _loc11_:MovieClip = null;
         var _loc6_:TextField = null;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc5_:WindowAndScrollbarGenerator = null;
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _numAchievementsLastDrawn = _myAchievements.length;
         var _loc7_:Array = SbiConstants.ACHIEVEMENT_TYPE_NAMES;
         var _loc8_:Array = AchievementManager.typeNamesTranslatedAndSorted;
         _allAchievementsIndexed = AchievementManager.getAllAchievementsIndexed();
         _sectionItemWindows = [];
         var _loc2_:TextFormat = (_achievementPopupContent.titleTxt as TextField).getTextFormat();
         _loc2_.size = 22;
         var _loc9_:int = int(_achievementPopupContent.itemBlockAll.width);
         var _loc10_:int = int(_achievementPopupContent.itemBlockAll.height);
         _loc4_ = 0;
         while(_loc4_ < _loc8_.length)
         {
            _loc12_ = _loc8_[_loc4_];
            _loc13_ = int(_allAchievementsIndexed[_loc12_.typeIndex].length);
            _loc14_ = Math.min(_loc13_,6);
            _loc3_ = Math.ceil(_loc14_ / 5);
            _loc11_ = new MovieClip();
            _loc6_ = new TextField();
            _loc6_.autoSize = "left";
            _loc6_.defaultTextFormat = _loc2_;
            _loc6_.embedFonts = true;
            _loc6_.antiAliasType = "advanced";
            _loc6_.setTextFormat(_loc2_);
            _loc6_.text = _loc12_.name;
            _loc11_.addChild(_loc6_);
            _loc5_ = new WindowAndScrollbarGenerator();
            _loc5_.init(_loc9_,_loc10_,0,0,1,1,0,0,0,5,0,ItemWindowWithSeparators,[_loc11_],"",0,null,null,null,true,false,false,true);
            _sectionItemWindows.push(_loc5_);
            _loc5_ = new WindowAndScrollbarGenerator();
            _loc5_.init(_loc9_,_loc10_,0,0,_loc14_,_loc3_,0,0,0,0,0,ItemWindowWithSeparators,_allAchievementsIndexed[_loc12_.typeIndex],"image",0,{
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut,
               "mouseDown":winMouseDown
            },{
               "itemClassName":"awardCont",
               "secondaryIndex":_loc4_ * 2 + 1,
               "myAchievementsByType":_myAchievementsIndexed[_loc12_.typeIndex]
            },null,true,false,false,true);
            _sectionItemWindows.push(_loc5_);
            _loc4_++;
         }
         _itemWindows = new WindowAndScrollbarGenerator();
         _itemWindows.init(_loc9_,_loc10_ - 8,0,0,1,_sectionItemWindows.length,0,0,0,0,0,ItemWindowWithSeparators,_sectionItemWindows,"");
         _itemWindows.y += 4;
         _achievementPopupContent.itemBlockAll.addChild(_itemWindows);
         selectAchievement(_sectionItemWindows[1].mediaWindows[0].currItemType,0);
         if(param1)
         {
            _loadingSpiral.visible = false;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.visible = false;
         }
      }
      
      private function selectAchievement(param1:int, param2:int) : void
      {
         var _loc4_:Achievement = null;
         var _loc6_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:Array = null;
         var _loc7_:int = 0;
         if(_allAchievementsIndexed[param1] && _allAchievementsIndexed[param1][param2])
         {
            while(_achievementPopupContent.itemBlockSingle.numChildren > 1)
            {
               _achievementPopupContent.itemBlockSingle.removeChildAt(_achievementPopupContent.itemBlockSingle.numChildren - 1);
            }
            _loc4_ = _allAchievementsIndexed[param1][param2].clone();
            LocalizationManager.updateToFit(_achievementPopupContent.achNameTxt,_loc4_.name);
            _loc6_ = Math.max(0,gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc4_.userVarId));
            _loc5_ = AchievementManager.getAchievementDef(_loc4_.defId);
            if(_loc6_ == 0)
            {
               _loc3_ = _myAchievementsIndexed[param1];
               if(_loc3_)
               {
                  _loc7_ = 0;
                  while(_loc7_ < _loc3_.length)
                  {
                     if(_loc3_[_loc7_].defId == _loc4_.defId)
                     {
                        _loc6_ = 1;
                        break;
                     }
                     _loc7_++;
                  }
               }
            }
            if(_loc6_ > _loc5_.triggeredAmount)
            {
               _loc6_ = int(_loc5_.triggeredAmount);
            }
            _achievementPopupContent.progressMeter.normalBar.width = (1 - _loc6_ / _loc5_.triggeredAmount) * _achievementPopupContent.progressMeter.greenBar.width;
            _achievementPopupContent.progressTxt.text = _loc6_ + "/" + _loc5_.triggeredAmount;
            _loc4_.setScale(2);
            _achievementPopupContent.itemBlockSingle.addChild(_loc4_.image);
            LocalizationManager.updateToFit(_achievementPopupContent.descText,_loc4_.descr);
         }
      }
      
      private function onPopupDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:Achievement = _allAchievementsIndexed[param1.currentTarget.currItemType][param1.currentTarget.index];
         GuiManager.toolTip.init(_achievementPopupContent.itemBlockAll,_loc2_.name,0,0);
         GuiManager.toolTip.startTimer(param1);
         var _loc3_:int = param1.currentTarget.y + (_itemWindows.mediaWindows[param1.currentTarget.secondaryIndex].y - _itemWindows.scrollYValue);
         if(_loc2_.baseImageMediaId == Achievement.BASE_RIBBON_ID)
         {
            _loc3_ += 42;
         }
         else if(_loc2_.baseImageMediaId == Achievement.BASE_MEDAL_ID)
         {
            _loc3_ += 56;
         }
         else
         {
            _loc3_ += 57;
         }
         var _loc5_:int = param1.currentTarget.x + param1.currentTarget.width * 0.5;
         var _loc4_:Number = GuiManager.toolTip.width * 0.5 - _loc5_;
         if(_loc4_ > 15)
         {
            _loc5_ += _loc4_ - 15;
         }
         GuiManager.toolTip.setPos(_loc5_,_loc3_);
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         selectAchievement(param1.currentTarget.currItemType,param1.currentTarget.index);
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function addEventListeners() : void
      {
         _achievementPopupContent.addEventListener("mouseDown",onPopupDownHandler,false,0,true);
         _achievementPopupContent.bx.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _achievementPopupContent.removeEventListener("mouseDown",onPopupDownHandler);
         _achievementPopupContent.bx.removeEventListener("mouseDown",onClose);
      }
   }
}

