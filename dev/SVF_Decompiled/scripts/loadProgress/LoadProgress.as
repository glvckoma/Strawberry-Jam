package loadProgress
{
   import com.sbi.loader.LoaderCacheEntry_Base;
   import com.sbi.loader.LoaderEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import localization.LocalizationManager;
   
   public class LoadProgress
   {
      public static const INITIALIZING:int = 2;
      
      public static const LOAD_RESOURCES:int = 3;
      
      public static const INIT_GAMEPLAY_OR_CREATE_ACCOUNT:int = 4;
      
      public static const LOGGING_IN:int = 5;
      
      public static const ON_LOGIN:int = 6;
      
      public static const INIT_ASSETS:int = 7;
      
      public static const LOADING_WORLDMAP:int = 8;
      
      public static const SCENE_INIT:int = 9;
      
      public static const LOADING_ROOM_OR_SERVER_JOIN:int = 10;
      
      public static const LIST_TOP_LOAD_TEXT_ID:int = 697;
      
      public static const LIST_BOTTOM_LOAD_TEXT_ID:int = 694;
      
      public static const LIST_PROGRESS_TEXT_ID:int = 696;
      
      private static var _entry:LoaderCacheEntry_Base;
      
      private static var _loadScreen:Loader;
      
      private static var _loadScreenContent:LoadProgressContent;
      
      private static var _loadLayer:DisplayObjectContainer;
      
      private static var _completeCallback:Function;
      
      private static var _target:String;
      
      private static var _bChangeLoadingScreen:Boolean;
      
      private static var _progressCounter:int;
      
      private static var _visible:Boolean;
      
      private static const LoadScreenSWF:Class = §Load_Screen_swf$5acc181bffdba49d4ccd552e7048a16f-378027654§;
      
      public function LoadProgress()
      {
         super();
      }
      
      public static function get loadScreen() : Loader
      {
         return _loadScreen;
      }
      
      public static function get entry() : LoaderCacheEntry_Base
      {
         return _entry;
      }
      
      public static function get loadLayer() : DisplayObjectContainer
      {
         return _loadLayer;
      }
      
      public static function get visible() : Boolean
      {
         return _visible;
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         var _loc2_:LoaderContext = null;
         if(_loadScreen == null)
         {
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
            _loadLayer = param1;
            _loadScreen = new Loader();
            _loc2_ = new LoaderContext();
            if(Capabilities.playerType === "Desktop")
            {
               _loc2_.allowCodeImport = true;
            }
            _loadScreen.contentLoaderInfo.addEventListener("complete",onLoadScreenComplete);
            _loadScreen.loadBytes(new LoadScreenSWF(),_loc2_);
         }
      }
      
      public static function show(param1:Boolean, param2:Object = null) : void
      {
         if(param1)
         {
            _visible = true;
            if(!loadLayer.contains(_loadScreen))
            {
               loadLayer.addChild(_loadScreen);
            }
            if(_loadScreenContent && _bChangeLoadingScreen)
            {
               _loadScreenContent.showScreen(true);
               _loadScreenContent.setProgress(_progressCounter);
               _bChangeLoadingScreen = false;
            }
         }
         else if(loadLayer.contains(_loadScreen))
         {
            _visible = false;
            loadLayer.removeChild(_loadScreen);
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
            if(_loadScreenContent)
            {
               _loadScreenContent.destroyScreens();
            }
         }
      }
      
      public static function updateProgress(param1:int) : void
      {
         _progressCounter = param1;
         if(_loadScreenContent)
         {
            _loadScreenContent.setProgress(param1);
         }
      }
      
      public static function load(param1:String, param2:int, param3:Function) : void
      {
         _entry = null;
         _completeCallback = param3;
         _target = gMainFrame.path + param1;
         _progressCounter = param2;
         if(_loadScreenContent)
         {
            _loadScreenContent.setProgress(param2);
         }
         if(_loadScreen)
         {
            startLoad();
            return;
         }
         throw new Error("preloader was not embedded?!");
      }
      
      public static function onLocalizationsReceived() : void
      {
         if(LocalizationManager.hasLocalizations)
         {
            if(_loadScreenContent)
            {
               _loadScreenContent.updateText();
            }
         }
      }
      
      private static function onLoadScreenComplete(param1:Event) : void
      {
         _loadScreenContent = new LoadProgressContent(MovieClip(_loadScreen.content));
         show(true);
      }
      
      private static function startLoad() : void
      {
         show(true);
         _loadScreenContent.loadPercentageVisibility = true;
         gMainFrame.loaderCache.openFile(_target,loadCompleteHandler,loadProgressHandler);
      }
      
      private static function loadCompleteHandler(param1:LoaderEvent) : void
      {
         _entry = param1.entry;
         _loadScreenContent.loadPercentageVisibility = false;
         if(_completeCallback != null)
         {
            _completeCallback();
         }
      }
      
      private static function loadProgressHandler(param1:LoaderEvent) : void
      {
         if(param1.status && _loadScreen)
         {
            _loadScreenContent.loadPercentage = param1.entry.progress;
            return;
         }
         throw new Error("ERROR: Unable to show loading progress! status:" + param1.status + " preloader:" + _loadScreen);
      }
   }
}

