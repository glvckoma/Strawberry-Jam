package achievement
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class AchievementManager
   {
      private static const ACHIEVEMENT_POPUP_MEDIA_ID:int = 2721;
      
      private static const STATE_IDLE:int = 0;
      
      private static const STATE_DISPLAYING:int = 1;
      
      private static var _newAchievements:Array;
      
      private static var _finishedCallbacks:Array;
      
      private static var _achievementDefs:Object;
      
      private static var _achievementDefsIndexed:Object;
      
      private static var _sortedTypeNames:Array;
      
      private static var _allAchievementsIndexed:Object;
      
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _achievementPopup:MovieClip;
      
      private static var _achievementImg:Sprite;
      
      private static var _popupDisplayTimer:Timer;
      
      private static var _popupDelayTimer:Timer;
      
      private static var _state:int;
      
      private static var _fpsLayer:DisplayObjectContainer;
      
      public function AchievementManager()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _fpsLayer = param1;
         _finishedCallbacks = [];
         _newAchievements = [];
         _popupDisplayTimer = new Timer(3000);
         _popupDelayTimer = new Timer(500);
         _state = 0;
      }
      
      public static function destroy() : void
      {
         _newAchievements.splice(0,_newAchievements.length);
         _newAchievements = null;
         _finishedCallbacks.splice(0,_finishedCallbacks.length);
         _finishedCallbacks = null;
         if(_popupDisplayTimer)
         {
            _popupDisplayTimer.stop();
            _popupDisplayTimer = null;
         }
         if(_popupDelayTimer)
         {
            _popupDelayTimer.stop();
            _popupDelayTimer = null;
         }
      }
      
      public static function hasAchievement() : Boolean
      {
         return false;
      }
      
      public static function displayNewAchievements(param1:Function = null) : void
      {
         if(param1 != null)
         {
            if(_finishedCallbacks.indexOf(param1) < 0 && _newAchievements.length > 0)
            {
               _finishedCallbacks.push(param1);
            }
            else
            {
               param1();
            }
         }
         if(_state == 0 && _newAchievements.length > 0)
         {
            _state = 1;
            displayNextAchievement();
         }
      }
      
      public static function set achievementDefs(param1:Object) : void
      {
         _achievementDefs = param1;
      }
      
      public static function set achievementDefsIndexed(param1:Object) : void
      {
         _achievementDefsIndexed = param1;
         for each(var _loc2_ in _achievementDefsIndexed)
         {
            _loc2_.sortOn(["sortIndex"],16);
         }
      }
      
      public static function get achievementDefs() : Object
      {
         return _achievementDefs;
      }
      
      public static function get achievementDefsIndexed() : Object
      {
         return _achievementDefsIndexed;
      }
      
      public static function getAchievementDef(param1:int) : Object
      {
         return _achievementDefs[param1];
      }
      
      public static function getAchievementDefsByType(param1:int) : Object
      {
         return _achievementDefsIndexed[param1];
      }
      
      public static function get typeNamesTranslatedAndSorted() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(_sortedTypeNames == null)
         {
            _sortedTypeNames = [];
            _loc1_ = SbiConstants.ACHIEVEMENT_TYPE_NAMES;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               _sortedTypeNames.push({
                  "typeIndex":_loc2_,
                  "name":LocalizationManager.translateIdOnly(_loc1_[_loc2_])
               });
               _loc2_++;
            }
            _sortedTypeNames.sortOn(["name"],[2,1]);
         }
         return _sortedTypeNames;
      }
      
      public static function getAllAchievementsIndexed() : Object
      {
         var _loc1_:Achievement = null;
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(_allAchievementsIndexed == null)
         {
            _allAchievementsIndexed = [];
            for each(var _loc5_ in _achievementDefsIndexed)
            {
               _allAchievementsIndexed.push([]);
               _loc4_ = 0;
               while(_loc4_ < _loc5_.length)
               {
                  _loc3_ = _loc5_[_loc4_];
                  if(_loc3_.iconMediaRef != 0 && _loc3_.descStrRef != 0 && _loc3_.descStrRef != 15476)
                  {
                     _loc1_ = new Achievement();
                     _loc1_.init(0,_loc3_.id,true);
                     _allAchievementsIndexed[_loc2_].push(_loc1_);
                  }
                  _loc4_++;
               }
               _loc2_++;
            }
         }
         return _allAchievementsIndexed;
      }
      
      private static function finishedDisplayingNewAchievements() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_finishedCallbacks.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _finishedCallbacks[_loc2_]();
            _loc2_++;
         }
         _finishedCallbacks.splice(0,_finishedCallbacks.length);
      }
      
      private static function displayNextAchievement() : void
      {
         var _loc1_:Achievement = _newAchievements[0];
         _achievementImg = _loc1_.image;
         _loc1_.setScale(2);
         _loc1_.setPosition(0.5,0.5);
         if(_achievementPopup)
         {
            _achievementPopup.achievementWindow.itemBlock.addChild(_achievementImg);
            LocalizationManager.updateToFit(_achievementPopup.achievementWindow.acmtNameTxt,_loc1_.name,false,false,false);
            _fpsLayer.addChild(_achievementPopup);
            _achievementPopup.gotoAndPlay(1);
            _achievementPopup.achievementWindow.gotoAndPlay(1);
            AJAudio.playAchievementSound();
            _popupDisplayTimer.start();
            _popupDisplayTimer.addEventListener("timer",onDisplayTimerFinished,false,0,true);
         }
         else
         {
            _popupMediaHelper = new MediaHelper();
            _popupMediaHelper.init(2721,popupHelperCallback);
         }
      }
      
      private static function onDisplayTimerFinished(param1:TimerEvent) : void
      {
         _popupDisplayTimer.stop();
         _fpsLayer.removeChild(_achievementPopup);
         _achievementPopup.achievementWindow.itemBlock.removeChild(_achievementImg);
         _newAchievements.splice(0,1);
         if(_newAchievements.length > 0)
         {
            _popupDelayTimer.start();
            _popupDelayTimer.addEventListener("timer",onDelayTimerFinished,false,0,true);
         }
         else
         {
            _state = 0;
            finishedDisplayingNewAchievements();
         }
      }
      
      private static function onDelayTimerFinished(param1:TimerEvent) : void
      {
         _popupDelayTimer.stop();
         displayNextAchievement();
      }
      
      private static function popupHelperCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            _achievementPopup = new MovieClip();
            _achievementPopup = param1;
            _achievementPopup.visible = true;
            _achievementPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
            displayNextAchievement();
         }
      }
      
      private static function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function addAchievement(param1:Achievement) : void
      {
         if(param1)
         {
            _newAchievements.push(param1);
         }
      }
   }
}

