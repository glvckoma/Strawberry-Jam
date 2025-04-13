package org.osmf.utils
{
   import flash.utils.Dictionary;
   
   public class OSMFStrings
   {
      public static const COMPOSITE_TRAIT_NOT_FOUND:String = "compositeTraitNotFound";
      
      public static const INVALID_PARAM:String = "invalidParam";
      
      public static const NULL_PARAM:String = "nullParam";
      
      public static const FUNCTION_MUST_BE_OVERRIDDEN:String = "functionMustBeOverridden";
      
      public static const ALREADY_ADDED:String = "alreadyAdded";
      
      public static const UNSUPPORTED_MEDIA_ELEMENT_TYPE:String = "unsupportedMediaElementType";
      
      public static const TRAIT_INSTANCE_ALREADY_ADDED:String = "traitInstanceAlreadyAdded";
      
      public static const TRAIT_RESOLVER_ALREADY_ADDED:String = "traitResolverAlreadyAdded";
      
      public static const CAPABILITY_NOT_SUPPORTED:String = "capabilityNotSupported";
      
      public static const MEDIA_LOAD_FAILED:String = "mediaLoadFailed";
      
      public static const MUST_SET_LOADER:String = "mustSetLoader";
      
      public static const LOADER_CANT_HANDLE_RESOURCE:String = "loaderCantHandleResource";
      
      public static const PAUSE_NOT_SUPPORTED:String = "pauseNotSupported";
      
      public static const ALREADY_READY:String = "alreadyReady";
      
      public static const ALREADY_LOADING:String = "alreadyLoading";
      
      public static const ALREADY_UNLOADED:String = "alreadyUnloaded";
      
      public static const ALREADY_UNLOADING:String = "alreadyUnloading";
      
      public static const INVALID_LAYOUT_RENDERER_CONSTRUCTOR:String = "invalidLayoutRendererConstructor";
      
      public static const ILLEGAL_CONSTRUCTOR_INVOCATION:String = "illegalConstructorInvocation";
      
      public static const DIRECT_DISPLAY_LIST_MOD_ERROR:String = "directDisplayListModError";
      
      public static const NULL_SCRIPT_PATH:String = "nullScriptPath";
      
      public static const STREAMSWITCH_INVALID_INDEX:String = "streamSwitchInvalidIndex";
      
      public static const STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE:String = "streamSwitchStreamNotInManualMode";
      
      public static const DRM_METADATA_NOT_SET:String = "drmMetadataNotSet";
      
      public static const DVR_MAXIMUM_RPC_ATTEMPTS:String = "dvrMaximumRPCAttempts";
      
      public static const DVR_UNEXPECTED_SERVER_RESPONSE:String = "dvrUnexpectedServerResponse";
      
      public static const F4M_PARSE_PROFILE_MISSING:String = "f4mProfileMissing";
      
      public static const F4M_PARSE_MEDIA_URL_MISSING:String = "f4mMediaURLMissing";
      
      public static const F4M_PARSE_BITRATE_MISSING:String = "f4mBitrateMissing";
      
      public static const IO_ERROR:String = "ioError";
      
      public static const SECURITY_ERROR:String = "securityError";
      
      public static const ASYNC_ERROR:String = "asyncError";
      
      public static const ARGUMENT_ERROR:String = "argumentError";
      
      public static const URL_SCHEME_INVALID:String = "urlSchemeInvalid";
      
      public static const HTTP_GET_FAILED:String = "httpGetFailed";
      
      public static const PLUGIN_VERSION_INVALID:String = "pluginVersionInvalid";
      
      public static const PLUGIN_IMPLEMENTATION_INVALID:String = "pluginImplementationInvalid";
      
      public static const SOUND_PLAY_FAILED:String = "soundPlayFailed";
      
      public static const NETCONNECTION_REJECTED:String = "netConnectionRejected";
      
      public static const NETCONNECTION_APPLICATION_INVALID:String = "netConnectionApplicationInvalid";
      
      public static const NETCONNECTION_FAILED:String = "netConnectionFailed";
      
      public static const NETCONNECTION_TIMEOUT:String = "netConnectionTimeout";
      
      public static const NETSTREAM_PLAY_FAILED:String = "netStreamPlayFailed";
      
      public static const NETSTREAM_STREAM_NOT_FOUND:String = "netStreamStreamNotFound";
      
      public static const NETSTREAM_FILE_STRUCTURE_INVALID:String = "netStreamFileStructureInvalid";
      
      public static const NETSTREAM_NO_SUPPORTED_TRACK_FOUND:String = "netStreamNoSupportedTrackFound";
      
      public static const DRM_SYSTEM_UPDATE_ERROR:String = "drmSystemUpdateError";
      
      public static const DVRCAST_SUBSCRIBE_FAILED:String = "dvrCastSubscribeFailed";
      
      public static const DVRCAST_CONTENT_OFFLINE:String = "dvrCastContentOffline";
      
      public static const DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:String = "dvrCastStreamInfoRetrievalFailed";
      
      public static const MULTICAST_PARAMETER_INVALID:String = "multicastParameterInvalid";
      
      public static const MULTICAST_NOT_SUPPORT_MBR:String = "multicastNotSupportMBR";
      
      public static const F4M_FILE_INVALID:String = "f4MFileINVALID";
      
      private static const resourceDict:Dictionary = new Dictionary();
      
      private static var _resourceStringFunction:Function = defaultResourceStringFunction;
      
      resourceDict["compositeTraitNotFound"] = "There is no composite trait for the given trait type";
      resourceDict["invalidParam"] = "Invalid parameter passed to method";
      resourceDict["nullParam"] = "Unexpected null parameter passed to method";
      resourceDict["functionMustBeOverridden"] = "Function must be overridden";
      resourceDict["alreadyAdded"] = "Child has already been added";
      resourceDict["unsupportedMediaElementType"] = "The specified media element type is not supported";
      resourceDict["traitInstanceAlreadyAdded"] = "An instance of this trait class has already been added to this MediaElement";
      resourceDict["traitResolverAlreadyAdded"] = "A trait resolver for the specified trait type has already been added to this MediaElement";
      resourceDict["capabilityNotSupported"] = "The specified capability is not currently supported";
      resourceDict["mediaLoadFailed"] = "The loading of a MediaElement failed";
      resourceDict["mustSetLoader"] = "Must set LoaderBase on a LoadTrait before calling load or unload";
      resourceDict["loaderCantHandleResource"] = "LoaderBase unable to handle the given MediaResourceBase";
      resourceDict["pauseNotSupported"] = "PlayTrait.pause cannot be invoked when canPause is false";
      resourceDict["alreadyReady"] = "Loader - attempt to load an already loaded object";
      resourceDict["alreadyLoading"] = "Loader - attempt to load a loading object";
      resourceDict["alreadyUnloaded"] = "Loader - attempt to unload an already unloaded object";
      resourceDict["alreadyUnloading"] = "Loader - attempt to unload a unloading object";
      resourceDict["invalidLayoutRendererConstructor"] = "Unable to construct LayoutRenderer implementation";
      resourceDict["illegalConstructorInvocation"] = "Use the static getInstance method to obtain a class instance";
      resourceDict["directDisplayListModError"] = "The direct addition or removal of display objects onto a MediaContainer is prohibited.";
      resourceDict["nullScriptPath"] = "Operation requires a valid script path";
      resourceDict["streamSwitchInvalidIndex"] = "Dynamic Stream Switching - Invalid index requested";
      resourceDict["streamSwitchStreamNotInManualMode"] = "Dynamic Stream Switching - stream is not in manual mode";
      resourceDict["drmMetadataNotSet"] = "Metadata not set on DRMServices";
      resourceDict["dvrMaximumRPCAttempts"] = "Maximum DVRGetStreamInfo RPC attempts (%i) reached";
      resourceDict["dvrUnexpectedServerResponse"] = "Unexpected server response: ";
      resourceDict["f4mProfileMissing"] = "Profile missing from Bootstrap info tag";
      resourceDict["f4mMediaURLMissing"] = "URL missing from Media tag";
      resourceDict["f4mBitrateMissing"] = "Bitrate missing from Media tag";
      resourceDict["ioError"] = "I/O error when loading media";
      resourceDict["securityError"] = "Security error when loading media";
      resourceDict["asyncError"] = "Async error when loading media";
      resourceDict["argumentError"] = "Argument error when loading media";
      resourceDict["urlSchemeInvalid"] = "Invalid URL scheme";
      resourceDict["httpGetFailed"] = "HTTP GET failed due to a Client Error (4xx Status Code)";
      resourceDict["pluginVersionInvalid"] = "Plugin failed to load due to version mismatch";
      resourceDict["pluginImplementationInvalid"] = "Plugin failed to load due to improper or missing implementation of PluginInfo";
      resourceDict["soundPlayFailed"] = "Playback failed due to no sound channels being available";
      resourceDict["netConnectionRejected"] = "Connection attempt rejected by FMS server";
      resourceDict["netConnectionApplicationInvalid"] = "Attempting to connect to an invalid FMS application";
      resourceDict["netConnectionFailed"] = "All NetConnection attempts failed";
      resourceDict["netConnectionTimeout"] = "Timed-out trying to establish a NetConnection, or timed out due to an idle NetConnection";
      resourceDict["netStreamPlayFailed"] = "Playback failed";
      resourceDict["netStreamStreamNotFound"] = "Stream not found";
      resourceDict["netStreamFileStructureInvalid"] = "File has invalid structure";
      resourceDict["netStreamNoSupportedTrackFound"] = "No supported track found";
      resourceDict["drmSystemUpdateError"] = "The update of the DRM subsystem failed";
      resourceDict["dvrCastSubscribeFailed"] = "DVRCast subscribe failed";
      resourceDict["dvrCastContentOffline"] = "DVRCast content is offline and unavailable";
      resourceDict["dvrCastStreamInfoRetrievalFailed"] = "Unable to retrieve DVRCast stream info";
      resourceDict["multicastParameterInvalid"] = "The groupspec or streamName is null or empty but not both";
      resourceDict["multicastNotSupportMBR"] = "Multicast does not support MBR";
      resourceDict["f4MFileINVALID"] = "The F4M document contains errors";
      resourceDict["missingStringResource"] = "No string for resource {0}";
      
      public function OSMFStrings()
      {
         super();
      }
      
      public static function getString(param1:String, param2:Array = null) : String
      {
         return resourceStringFunction(param1,param2);
      }
      
      public static function get resourceStringFunction() : Function
      {
         return _resourceStringFunction;
      }
      
      public static function set resourceStringFunction(param1:Function) : void
      {
         _resourceStringFunction = param1;
      }
      
      private static function defaultResourceStringFunction(param1:String, param2:Array = null) : String
      {
         var _loc3_:String = !!resourceDict.hasOwnProperty(param1) ? String(resourceDict[param1]) : null;
         if(_loc3_ == null)
         {
            _loc3_ = String(resourceDict["missingStringResource"]);
            param2 = [param1];
         }
         if(param2)
         {
            _loc3_ = substitute(_loc3_,param2);
         }
         return _loc3_;
      }
      
      private static function substitute(param1:String, ... rest) : String
      {
         var _loc5_:int = 0;
         var _loc4_:* = null;
         var _loc6_:int = 0;
         var _loc3_:* = "";
         if(param1 != null)
         {
            _loc3_ = param1;
            _loc5_ = int(rest.length);
            if(_loc5_ == 1 && rest[0] is Array)
            {
               _loc4_ = rest[0] as Array;
               _loc5_ = int(_loc4_.length);
            }
            else
            {
               _loc4_ = rest;
            }
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_ = _loc3_.replace(new RegExp("\\{" + _loc6_ + "\\}","g"),_loc4_[_loc6_]);
               _loc6_++;
            }
         }
         return _loc3_;
      }
   }
}

