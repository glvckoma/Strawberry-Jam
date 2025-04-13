package org.osmf.media
{
   import org.osmf.media.pluginClasses.VersionUtils;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.Version;
   
   public class PluginInfo
   {
      public static const PLUGIN_MEDIAFACTORY_NAMESPACE:String = "http://www.osmf.org/plugin/mediaFactory/1.0";
      
      private var _mediaFactoryItems:Vector.<MediaFactoryItem>;
      
      private var _mediaElementCreationNotificationFunction:Function;
      
      public function PluginInfo(param1:Vector.<MediaFactoryItem> = null, param2:Function = null)
      {
         super();
         _mediaFactoryItems = param1 != null ? param1 : new Vector.<MediaFactoryItem>();
         _mediaElementCreationNotificationFunction = param2;
      }
      
      public function get numMediaFactoryItems() : int
      {
         return _mediaFactoryItems.length;
      }
      
      public function get frameworkVersion() : String
      {
         return Version.version;
      }
      
      public function getMediaFactoryItemAt(param1:int) : MediaFactoryItem
      {
         if(param1 < 0 || param1 >= _mediaFactoryItems.length)
         {
            throw new RangeError(OSMFStrings.getString("invalidParam"));
         }
         return _mediaFactoryItems[param1] as MediaFactoryItem;
      }
      
      public function isFrameworkVersionSupported(param1:String) : Boolean
      {
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         var _loc3_:Object = VersionUtils.parseVersionString(param1);
         var _loc2_:Object = VersionUtils.parseVersionString(frameworkVersion);
         return _loc3_.major > _loc2_.major || _loc3_.major == _loc2_.major && _loc3_.minor >= _loc2_.minor;
      }
      
      public function initializePlugin(param1:MediaResourceBase) : void
      {
      }
      
      public function get mediaElementCreationNotificationFunction() : Function
      {
         return _mediaElementCreationNotificationFunction;
      }
      
      final protected function get mediaFactoryItems() : Vector.<MediaFactoryItem>
      {
         return _mediaFactoryItems;
      }
      
      final protected function set mediaFactoryItems(param1:Vector.<MediaFactoryItem>) : void
      {
         _mediaFactoryItems = param1;
      }
   }
}

