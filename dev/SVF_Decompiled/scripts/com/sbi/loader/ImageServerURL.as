package com.sbi.loader
{
   import com.sbi.corelib.Set;
   import com.sbi.graphics.ImageArrayHelper;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   
   public class ImageServerURL extends EventDispatcher
   {
      private static const IMAGE_ARRAY_PATH:String = "imageArrays/";
      
      private static const PALETTE_NAME:String = "paletteData";
      
      private static const CACHE_CLEANUP_INTERVAL_SECONDS:int = 10;
      
      public static const CACHE_TTL:int = 30;
      
      private static var _instance:ImageServerURL;
      
      private var _imageCacheArray:Array;
      
      private var _loaderCacheArray:Array;
      
      private var _layerInfo:Object;
      
      private var _timer:Timer;
      
      public function ImageServerURL(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use ImageServerURL.instance.");
         }
         _imageCacheArray = [];
         _loaderCacheArray = [];
         _timer = new Timer(10 * 1000);
         _timer.addEventListener("timer",heartbeat);
         _timer.start();
      }
      
      public static function get instance() : ImageServerURL
      {
         if(!_instance)
         {
            _instance = new ImageServerURL(SingletonLock);
         }
         return _instance;
      }
      
      public function set layerInfo(param1:Object) : void
      {
         _layerInfo = param1;
      }
      
      public function getLayerIndex(param1:int) : int
      {
         return _layerInfo[param1];
      }
      
      public function requestGlobalPalette() : void
      {
         var _loc1_:ImageServerEvent = null;
         var _loc2_:LoaderCacheEntry_URL = null;
         if(isGlobalPaletteCached())
         {
            _loc1_ = new ImageServerEvent("OnGlobalPalette");
            _loc1_.imageData = null;
            trace("imageServer dispatching cached game palette");
            dispatchEvent(_loc1_);
         }
         else
         {
            _loc2_ = _loaderCacheArray["palette"] = new LoaderCacheEntry_URL("paletteData");
            _loc2_.addEventListener("OnLoadComplete",onResultGetGamePalette,false,0,true);
            _loc2_.load();
         }
      }
      
      public function requestImage(param1:uint, param2:Boolean = true) : void
      {
         var _loc3_:LoaderCacheEntry_URL = null;
         if(!param2 || getFromCache(param1) == false)
         {
            if(!_loaderCacheArray[param1])
            {
               _loc3_ = _loaderCacheArray[param1] = new LoaderCacheEntry_URL("imageArrays/" + param1);
               _loc3_.id = param1;
               _loc3_.addEventListener("OnLoadComplete",onResultGetImageData,false,0,true);
               _loc3_.load();
            }
         }
      }
      
      public function requestImages(param1:Array) : void
      {
         for each(var _loc2_ in param1)
         {
            requestImage(_loc2_);
         }
      }
      
      private function heartbeat(param1:TimerEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Set = LayerAnim.trimAnims();
         for(var _loc4_ in _imageCacheArray)
         {
            if(!_loc3_.contains(_loc4_))
            {
               _loc2_ = _imageCacheArray[_loc4_];
               if(_loc2_.ttl-- < 1)
               {
                  delete _imageCacheArray[_loc4_];
               }
            }
         }
      }
      
      private function getFromCache(param1:uint) : Boolean
      {
         var _loc2_:Object = searchCache(param1);
         if(_loc2_)
         {
            _loc2_.ttl = 30;
            dispatchEvent(_loc2_.event.clone());
            return true;
         }
         return false;
      }
      
      private function isGlobalPaletteCached() : Boolean
      {
         return Boolean(PaletteHelper.gamePalette);
      }
      
      private function searchCache(param1:uint) : Object
      {
         return _imageCacheArray[param1];
      }
      
      private function onResultGetGamePalette(param1:LoaderEvent) : void
      {
         var _loc7_:ImageServerEvent = null;
         var _loc8_:ByteArray = null;
         var _loc6_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            _loaderCacheArray["palette"].removeEventListener("OnLoadComplete",onResultGetGamePalette);
            delete _loaderCacheArray["palette"];
            _loc7_ = new ImageServerEvent("OnGlobalPalette");
            _loc8_ = param1.entry.data as ByteArray;
            _loc6_ = new ByteArray();
            _loc3_ = new ByteArray();
            _loc4_ = new ByteArray();
            _loc8_.position = 0;
            _loc2_ = _loc8_.readInt();
            _loc5_ = 4;
            _loc6_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc6_.position = 0;
            _loc5_ += _loc2_;
            _loc8_.position = _loc5_;
            _loc2_ = _loc8_.readInt();
            _loc5_ += 4;
            _loc3_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc3_.position = 0;
            _loc5_ += _loc2_;
            _loc8_.position = _loc5_;
            _loc2_ = _loc8_.readInt();
            _loc5_ += 4;
            _loc4_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc4_.position = 0;
            _loc7_.genericData = {
               "palette":_loc6_,
               "avatarPalette1":_loc3_,
               "avatarPalette2":_loc4_
            };
            dispatchEvent(_loc7_);
            return;
         }
         throw new Error("Got 0 for GetGamePalette request!");
      }
      
      private function onResultGetImageData(param1:LoaderEvent) : void
      {
         _loaderCacheArray[param1.entry.id].removeEventListener("OnLoadComplete",onResultGetImageData);
         delete _loaderCacheArray[param1.entry.id];
         var _loc2_:ImageServerEvent = new ImageServerEvent("OnNewData");
         _loc2_.id = param1.entry.id;
         var _loc3_:Object = param1.entry.data;
         if(_loc3_ == null)
         {
            _imageCacheArray[_loc2_.id] = {
               "event":_loc2_,
               "ttl":30
            };
            _loc2_.success = false;
         }
         else
         {
            if(_loc3_.v != 117967104)
            {
               throw new Error("ERROR: Unrecognized version number(" + _loc3_.v.toString(16) + ")!");
            }
            _loc2_.imageData = _loc3_;
            _loc2_.layer = _layerInfo[ImageArrayHelper.layerId(_loc2_.id)];
            _loc2_.frames = _loc3_.f.length;
            _imageCacheArray[_loc2_.id] = {
               "event":_loc2_,
               "ttl":30
            };
         }
         dispatchEvent(_loc2_);
      }
   }
}

class SingletonLock
{
   public function SingletonLock()
   {
      super();
   }
}
