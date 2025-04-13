package org.osmf.media
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.elements.ProxyElement;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.PluginManagerEvent;
   import org.osmf.media.pluginClasses.PluginManager;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaFactory extends EventDispatcher
   {
      private var pluginManager:PluginManager;
      
      private var allItems:Dictionary;
      
      public function MediaFactory()
      {
         super();
         allItems = new Dictionary();
      }
      
      private static function getItemsByResource(param1:MediaResourceBase, param2:Vector.<MediaFactoryItem>) : Vector.<MediaFactoryItem>
      {
         var _loc4_:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
         for each(var _loc3_ in param2)
         {
            if(_loc3_.canHandleResourceFunction(param1))
            {
               _loc4_.push(_loc3_);
            }
         }
         return _loc4_;
      }
      
      private static function getIndexOfItem(param1:String, param2:Vector.<MediaFactoryItem>) : int
      {
         var _loc4_:int = 0;
         var _loc3_:MediaFactoryItem = null;
         _loc4_ = 0;
         while(_loc4_ < param2.length)
         {
            _loc3_ = param2[_loc4_] as MediaFactoryItem;
            if(_loc3_.id == param1)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         return -1;
      }
      
      public function addItem(param1:MediaFactoryItem) : void
      {
         if(param1 == null || param1.id == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc2_:Vector.<MediaFactoryItem> = findOrCreateItems(param1.type);
         var _loc3_:int = getIndexOfItem(param1.id,_loc2_);
         if(_loc3_ != -1)
         {
            _loc2_[_loc3_] = param1;
         }
         else
         {
            _loc2_.push(param1);
         }
      }
      
      public function removeItem(param1:MediaFactoryItem) : void
      {
         var _loc3_:int = 0;
         if(param1 == null || param1.id == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc2_:Vector.<MediaFactoryItem> = allItems[param1.type];
         if(_loc2_ != null)
         {
            _loc3_ = int(_loc2_.indexOf(param1));
            if(_loc3_ != -1)
            {
               _loc2_.splice(_loc3_,1);
            }
         }
      }
      
      public function get numItems() : int
      {
         var _loc2_:* = undefined;
         var _loc3_:int = 0;
         for each(var _loc1_ in MediaFactoryItemType.ALL_TYPES)
         {
            _loc2_ = allItems[_loc1_];
            if(_loc2_ != null)
            {
               _loc3_ += _loc2_.length;
            }
         }
         return _loc3_;
      }
      
      public function getItemAt(param1:int) : MediaFactoryItem
      {
         var _loc4_:* = undefined;
         var _loc2_:MediaFactoryItem = null;
         if(param1 >= 0)
         {
            for each(var _loc3_ in MediaFactoryItemType.ALL_TYPES)
            {
               _loc4_ = allItems[_loc3_];
               if(_loc4_ != null)
               {
                  if(param1 < _loc4_.length)
                  {
                     _loc2_ = _loc4_[param1];
                     break;
                  }
                  param1 -= _loc4_.length;
               }
            }
         }
         return _loc2_;
      }
      
      public function getItemById(param1:String) : MediaFactoryItem
      {
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc2_:MediaFactoryItem = null;
         for each(var _loc3_ in MediaFactoryItemType.ALL_TYPES)
         {
            _loc4_ = allItems[_loc3_];
            if(_loc4_ != null)
            {
               _loc5_ = getIndexOfItem(param1,_loc4_);
               if(_loc5_ != -1)
               {
                  _loc2_ = _loc4_[_loc5_];
                  break;
               }
            }
         }
         return _loc2_;
      }
      
      public function loadPlugin(param1:MediaResourceBase) : void
      {
         createPluginManager();
         pluginManager.loadPlugin(param1);
      }
      
      public function createMediaElement(param1:MediaResourceBase) : MediaElement
      {
         var _loc3_:MediaElement = null;
         createPluginManager();
         var _loc2_:MediaElement = createMediaElementByResource(param1,"standard");
         if(_loc2_ != null)
         {
            _loc3_ = createMediaElementByResource(_loc2_.resource,"proxy",_loc2_);
            _loc2_ = _loc3_ != null ? _loc3_ : _loc2_;
            dispatchEvent(new MediaFactoryEvent("mediaElementCreate",false,false,null,_loc2_));
         }
         return _loc2_;
      }
      
      protected function resolveItems(param1:MediaResourceBase, param2:Vector.<MediaFactoryItem>) : MediaFactoryItem
      {
         var _loc5_:int = 0;
         var _loc3_:MediaFactoryItem = null;
         if(param1 == null || param2 == null)
         {
            return null;
         }
         var _loc4_:* = null;
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc3_ = param2[_loc5_] as MediaFactoryItem;
            if(_loc3_.id.indexOf("org.osmf") == -1)
            {
               return _loc3_;
            }
            if(_loc4_ == null)
            {
               _loc4_ = _loc3_;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function findOrCreateItems(param1:String) : Vector.<MediaFactoryItem>
      {
         if(allItems[param1] == null)
         {
            allItems[param1] = new Vector.<MediaFactoryItem>();
         }
         return allItems[param1] as Vector.<MediaFactoryItem>;
      }
      
      private function createMediaElementByResource(param1:MediaResourceBase, param2:String, param3:MediaElement = null) : MediaElement
      {
         var _loc4_:MediaFactoryItem = null;
         var _loc8_:* = null;
         var _loc6_:int = 0;
         var _loc7_:MediaFactoryItem = null;
         var _loc9_:ProxyElement = null;
         var _loc5_:* = null;
         var _loc10_:Vector.<MediaFactoryItem> = getItemsByResource(param1,allItems[param2]);
         if(param2 == "standard")
         {
            _loc4_ = resolveItems(param1,_loc10_) as MediaFactoryItem;
            if(_loc4_ != null)
            {
               _loc5_ = invokeMediaElementCreationFunction(_loc4_);
            }
         }
         else if(param2 == "proxy")
         {
            _loc8_ = param3;
            _loc6_ = int(_loc10_.length);
            while(_loc6_ > 0)
            {
               _loc7_ = _loc10_[_loc6_ - 1] as MediaFactoryItem;
               _loc9_ = invokeMediaElementCreationFunction(_loc7_) as ProxyElement;
               if(_loc9_ != null)
               {
                  _loc9_.proxiedElement = _loc8_;
                  _loc8_ = _loc9_;
               }
               _loc6_--;
            }
            _loc5_ = _loc8_;
         }
         if(_loc5_ != null)
         {
            _loc5_.resource = param1;
         }
         return _loc5_;
      }
      
      private function onPluginLoad(param1:PluginManagerEvent) : void
      {
         dispatchEvent(new MediaFactoryEvent("pluginLoad",false,false,param1.resource));
      }
      
      private function onPluginLoadError(param1:PluginManagerEvent) : void
      {
         dispatchEvent(new MediaFactoryEvent("pluginLoadError",false,false,param1.resource));
      }
      
      private function invokeMediaElementCreationFunction(param1:MediaFactoryItem) : MediaElement
      {
         var _loc2_:MediaElement = null;
         try
         {
            _loc2_ = param1.mediaElementCreationFunction();
         }
         catch(error:Error)
         {
         }
         return _loc2_;
      }
      
      private function createPluginManager() : void
      {
         if(pluginManager == null)
         {
            pluginManager = new PluginManager(this);
            pluginManager.addEventListener("pluginLoad",onPluginLoad);
            pluginManager.addEventListener("pluginLoadError",onPluginLoadError);
         }
      }
   }
}

