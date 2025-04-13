package org.osmf.media.pluginClasses
{
   import flash.display.Loader;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.PluginInfo;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.Version;
   
   internal class PluginLoader extends LoaderBase
   {
      private static const FRAMEWORK_VERSION_PROPERTY_NAME:String = "frameworkVersion";
      
      private static const IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME:String = "isFrameworkVersionSupported";
      
      private var minimumSupportedFrameworkVersion:String;
      
      private var mediaFactory:MediaFactory;
      
      public function PluginLoader(param1:MediaFactory, param2:String)
      {
         super();
         this.mediaFactory = param1;
         this.minimumSupportedFrameworkVersion = param2;
      }
      
      protected function unloadFromPluginInfo(param1:PluginInfo) : void
      {
         var _loc4_:int = 0;
         var _loc2_:MediaFactoryItem = null;
         var _loc3_:MediaFactoryItem = null;
         if(param1 != null)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.numMediaFactoryItems)
            {
               _loc2_ = param1.getMediaFactoryItemAt(_loc4_);
               _loc3_ = mediaFactory.getItemById(_loc2_.id);
               if(_loc3_ != null)
               {
                  mediaFactory.removeItem(_loc3_);
               }
               _loc4_++;
            }
         }
      }
      
      protected function loadFromPluginInfo(param1:LoadTrait, param2:PluginInfo, param3:Loader = null) : void
      {
         var _loc4_:MediaFactory = null;
         var _loc7_:int = 0;
         var _loc5_:MediaFactoryItem = null;
         var _loc6_:PluginLoadTrait = null;
         var _loc8_:Boolean = false;
         if(param2 != null)
         {
            if(isPluginCompatible(param2))
            {
               try
               {
                  _loc4_ = param1.resource.getMetadataValue("http://www.osmf.org/plugin/mediaFactory/1.0") as MediaFactory;
                  if(_loc4_ == null)
                  {
                     param1.resource.addMetadataValue("http://www.osmf.org/plugin/mediaFactory/1.0",mediaFactory);
                  }
                  param2.initializePlugin(param1.resource);
                  _loc7_ = 0;
                  while(_loc7_ < param2.numMediaFactoryItems)
                  {
                     _loc5_ = param2.getMediaFactoryItemAt(_loc7_);
                     if(_loc5_ == null)
                     {
                        throw new RangeError();
                     }
                     mediaFactory.addItem(_loc5_);
                     _loc7_++;
                  }
                  _loc6_ = param1 as PluginLoadTrait;
                  _loc6_.pluginInfo = param2;
                  _loc6_.loader = param3;
                  updateLoadTrait(_loc6_,"ready");
               }
               catch(error:RangeError)
               {
                  _loc8_ = true;
               }
            }
            else
            {
               updateLoadTrait(param1,"loadError");
               param1.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(8)));
            }
         }
         else
         {
            _loc8_ = true;
         }
         if(_loc8_)
         {
            updateLoadTrait(param1,"loadError");
            param1.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(9)));
         }
      }
      
      protected function isPluginCompatible(param1:Object) : Boolean
      {
         var _loc2_:Function = null;
         var _loc5_:Boolean = false;
         var _loc4_:String = !!param1.hasOwnProperty("frameworkVersion") ? param1["frameworkVersion"] : null;
         var _loc3_:Boolean = isPluginVersionSupported(_loc4_);
         if(_loc3_)
         {
            _loc2_ = !!param1.hasOwnProperty("isFrameworkVersionSupported") ? param1["isFrameworkVersionSupported"] as Function : null;
            if(_loc2_ != null)
            {
               try
               {
                  _loc5_ = _loc2_(Version.version);
               }
               catch(error:Error)
               {
               }
            }
         }
         return _loc5_;
      }
      
      private function isPluginVersionSupported(param1:String) : Boolean
      {
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         var _loc2_:Object = VersionUtils.parseVersionString(minimumSupportedFrameworkVersion);
         var _loc3_:Object = VersionUtils.parseVersionString(param1);
         return _loc3_.major > _loc2_.major || _loc3_.major == _loc2_.major && _loc3_.minor >= _loc2_.minor;
      }
   }
}

