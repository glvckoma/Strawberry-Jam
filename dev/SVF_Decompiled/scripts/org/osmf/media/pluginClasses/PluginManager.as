package org.osmf.media.pluginClasses
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.PluginManagerEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfoResource;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.Version;
   
   public class PluginManager extends EventDispatcher
   {
      private static const STATIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.StaticPluginLoader";
      
      private static const DYNAMIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.DynamicPluginLoader";
      
      private var _mediaFactory:MediaFactory;
      
      private var _pluginFactory:MediaFactory;
      
      private var _pluginMap:Dictionary;
      
      private var _pluginList:Vector.<PluginEntry>;
      
      private var notificationFunctions:Vector.<Function>;
      
      private var createdElements:Dictionary;
      
      private var minimumSupportedFrameworkVersion:String;
      
      private var staticPluginLoader:StaticPluginLoader;
      
      private var dynamicPluginLoader:DynamicPluginLoader;
      
      public function PluginManager(param1:MediaFactory)
      {
         super();
         _mediaFactory = param1;
         _mediaFactory.addEventListener("mediaElementCreate",onMediaElementCreate);
         minimumSupportedFrameworkVersion = Version.lastAPICompatibleVersion;
         initPluginFactory();
         _pluginMap = new Dictionary();
         _pluginList = new Vector.<PluginEntry>();
      }
      
      public function loadPlugin(param1:MediaResourceBase) : void
      {
         var identifier:Object;
         var pluginEntry:PluginEntry;
         var pluginElement:MediaElement;
         var loadTrait:LoadTrait;
         var resource:MediaResourceBase = param1;
         var onLoadStateChange:* = function(param1:LoadEvent):void
         {
            var _loc2_:PluginLoadTrait = null;
            if(param1.loadState == "ready")
            {
               pluginEntry.state = PluginLoadingState.LOADED;
               _pluginList.push(pluginEntry);
               _loc2_ = pluginElement.getTrait("load") as PluginLoadTrait;
               if(_loc2_.pluginInfo.mediaElementCreationNotificationFunction != null)
               {
                  invokeMediaElementCreationNotificationForCreatedMediaElements(_loc2_.pluginInfo.mediaElementCreationNotificationFunction);
                  if(notificationFunctions == null)
                  {
                     notificationFunctions = new Vector.<Function>();
                  }
                  notificationFunctions.push(_loc2_.pluginInfo.mediaElementCreationNotificationFunction);
               }
               dispatchEvent(new PluginManagerEvent("pluginLoad",false,false,resource));
            }
            else if(param1.loadState == "loadError")
            {
               delete _pluginMap[identifier];
               dispatchEvent(new PluginManagerEvent("pluginLoadError",false,false,resource));
            }
         };
         var onMediaError:* = function(param1:MediaErrorEvent):void
         {
            dispatchEvent(param1.clone());
         };
         if(resource == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         identifier = getPluginIdentifier(resource);
         pluginEntry = _pluginMap[identifier] as PluginEntry;
         if(pluginEntry != null)
         {
            dispatchEvent(new PluginManagerEvent("pluginLoad",false,false,resource));
         }
         else
         {
            pluginElement = _pluginFactory.createMediaElement(resource);
            if(pluginElement != null)
            {
               pluginEntry = new PluginEntry(pluginElement,PluginLoadingState.LOADING);
               _pluginMap[identifier] = pluginEntry;
               loadTrait = pluginElement.getTrait("load") as LoadTrait;
               if(loadTrait != null)
               {
                  loadTrait.addEventListener("loadStateChange",onLoadStateChange);
                  loadTrait.addEventListener("mediaError",onMediaError);
                  loadTrait.load();
               }
               else
               {
                  dispatchEvent(new PluginManagerEvent("pluginLoadError",false,false,resource));
               }
            }
            else
            {
               dispatchEvent(new PluginManagerEvent("pluginLoadError",false,false,resource));
            }
         }
      }
      
      public function get mediaFactory() : MediaFactory
      {
         return _mediaFactory;
      }
      
      private function getPluginIdentifier(param1:MediaResourceBase) : Object
      {
         var _loc2_:Object = null;
         if(param1 is URLResource)
         {
            _loc2_ = (param1 as URLResource).url;
         }
         else if(param1 is PluginInfoResource)
         {
            _loc2_ = (param1 as PluginInfoResource).pluginInfo;
         }
         return _loc2_;
      }
      
      private function initPluginFactory() : void
      {
         _pluginFactory = new MediaFactory();
         staticPluginLoader = new StaticPluginLoader(mediaFactory,minimumSupportedFrameworkVersion);
         dynamicPluginLoader = new DynamicPluginLoader(mediaFactory,minimumSupportedFrameworkVersion);
         var _loc1_:MediaFactoryItem = new MediaFactoryItem("org.osmf.plugins.StaticPluginLoader",staticPluginLoader.canHandleResource,createStaticPluginElement);
         _pluginFactory.addItem(_loc1_);
         var _loc2_:MediaFactoryItem = new MediaFactoryItem("org.osmf.plugins.DynamicPluginLoader",dynamicPluginLoader.canHandleResource,createDynamicPluginElement);
         _pluginFactory.addItem(_loc2_);
      }
      
      private function createStaticPluginElement() : MediaElement
      {
         return new PluginElement(staticPluginLoader);
      }
      
      private function createDynamicPluginElement() : MediaElement
      {
         return new PluginElement(dynamicPluginLoader);
      }
      
      private function onMediaElementCreate(param1:MediaFactoryEvent) : void
      {
         invokeMediaElementCreationNotifications(param1.mediaElement);
         if(createdElements == null)
         {
            createdElements = new Dictionary(true);
         }
         createdElements[param1.mediaElement] = true;
      }
      
      private function invokeMediaElementCreationNotifications(param1:MediaElement) : void
      {
         for each(var _loc2_ in notificationFunctions)
         {
            invokeMediaElementCreationNotificationFunction(_loc2_,param1);
         }
      }
      
      private function invokeMediaElementCreationNotificationFunction(param1:Function, param2:MediaElement) : void
      {
         try
         {
            param1.call(null,param2);
         }
         catch(error:Error)
         {
         }
      }
      
      private function invokeMediaElementCreationNotificationForCreatedMediaElements(param1:Function) : void
      {
         for(var _loc2_ in createdElements)
         {
            invokeMediaElementCreationNotificationFunction(param1,_loc2_ as MediaElement);
         }
      }
   }
}

