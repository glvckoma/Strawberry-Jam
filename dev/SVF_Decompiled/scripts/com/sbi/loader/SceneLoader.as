package com.sbi.loader
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.Dictionary;
   import localization.LocalizationManager;
   
   public class SceneLoader extends EventDispatcher
   {
      public static const LOAD_STATE_NOTLOADED:int = 0;
      
      public static const LOAD_STATE_LOADING:int = 1;
      
      public static const LOAD_STATE_LOADED:int = 2;
      
      private var _offset:Point;
      
      private var _scene:Object;
      
      private var _loaderCount:int;
      
      private var _loader:Array;
      
      private var _loadedAssets:Dictionary;
      
      private var _loaderLUT:Dictionary;
      
      private var _initCount:int;
      
      private var _loadProgressCallback:Function;
      
      public var _useDynamicLoading:Boolean;
      
      public function SceneLoader(param1:Function = null)
      {
         super();
         _loader = [];
         _loadProgressCallback = param1;
      }
      
      public function getOffset(param1:DisplayObject) : Point
      {
         var _loc5_:* = null;
         var _loc3_:Loader = null;
         var _loc2_:Rectangle = null;
         var _loc4_:Array = getActorList("ActorLayer");
         for each(_loc5_ in _loc4_)
         {
            _loc3_ = _loc5_.s;
            _loc2_ = _loc3_.getBounds(param1);
            if(_loc2_.x < _offset.x)
            {
               _offset.x = _loc2_.x;
            }
            if(_loc2_.y < _offset.y)
            {
               _offset.y = _loc2_.y;
            }
         }
         return _offset;
      }
      
      public function get isValid() : Boolean
      {
         return _scene != null;
      }
      
      public function get sceneObject() : Object
      {
         return _scene;
      }
      
      public function setScene(param1:Object, param2:Boolean = false) : void
      {
         release();
         _scene = param1;
         _loadedAssets = new Dictionary();
         _loaderLUT = new Dictionary();
         if(param1)
         {
            loadLayers(param2);
         }
      }
      
      public function getActorList(param1:String) : Array
      {
         return _scene.actors[param1];
      }
      
      public function getLayer(param1:String) : Object
      {
         return findLayer(param1);
      }
      
      public function cloneAsset(param1:String) : Object
      {
         var _loc2_:Loader = null;
         var _loc3_:Object = findLayer(param1);
         if(_loc3_)
         {
            _loc2_ = newAsset(_loc3_.assetName);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            _loc3_.loader = _loc2_;
         }
         return _loc3_;
      }
      
      public function release() : void
      {
         var _loc1_:Loader = null;
         while(_loader.length)
         {
            _loc1_ = _loader.pop();
            _loc1_.unloadAndStop();
         }
      }
      
      public function releaseCloneAsset(param1:Loader) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Loader = null;
         while(_loc2_ < _loader.length)
         {
            _loc3_ = _loader[_loc2_];
            if(_loc3_ == param1)
            {
               param1.unloadAndStop();
               _loader.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function forceLoadComplete() : void
      {
         _loadProgressCallback();
      }
      
      private function findLayer(param1:String) : Object
      {
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         var _loc2_:Array = getActorList("ActorLayer");
         param1 = param1.toLowerCase();
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].name == param1)
            {
               _loc4_ = {};
               _loc4_.assetName = _loc2_[_loc3_].assetName;
               _loc4_.loader = _loc2_[_loc3_].s;
               _loc4_.height = _loc2_[_loc3_].s.height;
               _loc4_.width = _loc2_[_loc3_].s.width;
               _loc4_.x = _loc2_[_loc3_].s.x;
               _loc4_.y = _loc2_[_loc3_].s.y;
               _loc4_.flip = _loc2_[_loc3_].flip;
               break;
            }
            _loc3_++;
         }
         if(_loc4_ == null)
         {
            trace("Layer Not Found: " + param1);
         }
         return _loc4_;
      }
      
      private function newAsset(param1:String) : Loader
      {
         var _loc4_:Loader = null;
         var _loc3_:int = 0;
         param1 = param1.toLowerCase();
         var _loc2_:Array = _scene.assets;
         while(_loc3_ < _loc2_.length)
         {
            if(_loc2_[_loc3_].name.toLowerCase() == param1)
            {
               _loc4_ = new Loader();
               _loc4_.loadBytes(_loc2_[_loc3_].ba);
               _loc4_.contentLoaderInfo.addEventListener("complete",onNewLoaderComplete);
               _loader.push(_loc4_);
               return _loc4_;
            }
            _loc3_++;
         }
         return _loc4_;
      }
      
      private function onNewLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener("complete",onLoaderComplete);
         if(!Utility.doesItAnimate(_loc2_.content))
         {
            _loc2_.content.cacheAsBitmap = true;
         }
         dispatchEvent(param1);
      }
      
      public function loadLayer(param1:Object) : void
      {
         param1.loaded = 1;
         _loaderLUT[param1.s] = param1;
         var _loc2_:Loader = loadAsset(param1.assetName,param1.s);
         _initCount++;
      }
      
      public function isValidDynamicAsset(param1:Object) : Boolean
      {
         return param1.name == "" && param1.typeIndex != 1 && param1.typeIndex != 2 && param1.dx == 1 && param1.dy == 1;
      }
      
      private function loadLayers(param1:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc6_:Object = null;
         var _loc5_:Loader = null;
         _offset = new Point(9999999,9999999);
         var _loc2_:Array = getActorList("ActorLayer");
         _loaderCount = _loc2_.length;
         _initCount = 0;
         if(_loc2_.length > 0 && _loc2_[0].hasOwnProperty("top") && !param1)
         {
            _useDynamicLoading = true;
         }
         else
         {
            _useDynamicLoading = false;
         }
         var _loc3_:Boolean = false;
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc4_];
            _loc6_.dx = _loc6_.scrollX;
            _loc6_.dy = _loc6_.scrollY;
            if(_useDynamicLoading)
            {
               _loc6_.offsetX = _loc6_.left - _loc6_.x;
               _loc6_.offsetY = _loc6_.top - _loc6_.y;
               if(_loc6_.flip & 1)
               {
                  _loc6_.offsetX -= _loc6_.width;
               }
               if(_loc6_.flip & 2)
               {
                  _loc6_.offsetY -= _loc6_.height;
               }
            }
            else
            {
               _loc6_.offsetX = 0;
               _loc6_.offsetY = 0;
            }
            if(_useDynamicLoading && _loc3_ && isValidDynamicAsset(_loc6_))
            {
               _loaderCount--;
               _loc5_ = new Loader();
               _loc6_.loaded = 0;
            }
            else
            {
               _loc6_.loaded = 1;
               _loadedAssets[_loc6_.assetName] = _loc5_ = loadAsset(_loc6_.assetName);
               _loc3_ = true;
            }
            _loc6_.s = _loc5_;
            _loaderLUT[_loc5_] = _loc6_;
            _loc5_.x = Math.round(_loc6_.x);
            _loc5_.y = Math.round(_loc6_.y);
            _loc5_.rotation = _loc6_.rot;
            _loc5_.scaleX = _loc6_.scaleX;
            _loc5_.scaleY = _loc6_.scaleY;
            _loc4_++;
         }
      }
      
      private function loadAsset(param1:String, param2:Loader = null) : Loader
      {
         var _loc4_:int = 0;
         var _loc5_:LoaderContext = null;
         var _loc6_:* = param2;
         param1 = param1.toLowerCase();
         var _loc3_:Array = _scene.assets;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].name.toLowerCase() == param1)
            {
               if(_loc6_ == null)
               {
                  _loc6_ = new Loader();
               }
               if(_loc3_[_loc4_].ba)
               {
                  _loc5_ = new LoaderContext(false,ApplicationDomain.currentDomain);
                  _loc5_.allowCodeImport = true;
                  _loc6_.loadBytes(_loc3_[_loc4_].ba,_loc5_);
                  _loc6_.contentLoaderInfo.addEventListener("complete",onLoaderComplete);
                  _loader.push(_loc6_);
               }
               return _loc6_;
            }
            _loc4_++;
         }
         return _loc6_;
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener("complete",onLoaderComplete);
         if(_loc2_.content is MovieClip)
         {
            LocalizationManager.findAllTextfields(_loc2_.content);
            if(!Utility.doesItAnimate(_loc2_.content))
            {
               _loc2_.content.cacheAsBitmap = true;
            }
         }
         _loaderCount--;
         _loaderLUT[_loc2_.loader].loaded = 2;
         if(_initCount > 0)
         {
            _initCount--;
            if(_initCount == 0)
            {
               _loadProgressCallback();
            }
         }
         if(_loaderCount == 0)
         {
            allLoadingComplete();
         }
      }
      
      private function allLoadingComplete() : void
      {
         var _loc1_:Event = new Event("complete");
         dispatchEvent(_loc1_);
      }
   }
}

