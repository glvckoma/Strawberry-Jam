package org.osmf.elements
{
   import flash.errors.IOError;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import org.osmf.elements.audioClasses.SoundLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.URL;
   
   public class SoundLoader extends LoaderBase
   {
      private static const MIN_BYTES_TO_RECEIVE:int = 16;
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["audio/mpeg"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["audio"]);
      
      private var checkPolicyFile:Boolean;
      
      public function SoundLoader(param1:Boolean = false)
      {
         super();
         this.checkPolicyFile = param1;
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:int = MediaTypeUtil.checkMetadataMatchWithResource(param1,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(_loc2_ != 2)
         {
            return _loc2_ == 0;
         }
         var _loc3_:URLResource = param1 as URLResource;
         if(_loc3_ == null || _loc3_.url == null || _loc3_.url.length <= 0)
         {
            return false;
         }
         var _loc4_:URL = new URL(_loc3_.url);
         if(_loc4_.protocol == "")
         {
            return _loc4_.path.search(/\.mp3$|\.m4a$/i) != -1;
         }
         if(_loc4_.protocol.search(/file$|http$|https$/i) != -1)
         {
            return _loc4_.path == null || _loc4_.path.length <= 0 || _loc4_.path.indexOf(".") == -1 || _loc4_.path.search(/\.mp3$|\.m4a$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         var sound:Sound;
         var urlRequest:URLRequest;
         var context:SoundLoaderContext;
         var loadTrait:LoadTrait = param1;
         var toggleSoundListeners:* = function(param1:Sound, param2:Boolean):void
         {
            if(param2)
            {
               param1.addEventListener("progress",onProgress);
               param1.addEventListener("ioError",onIOError);
            }
            else
            {
               param1.removeEventListener("progress",onProgress);
               param1.removeEventListener("ioError",onIOError);
            }
         };
         var onProgress:* = function(param1:ProgressEvent):void
         {
            if(param1.bytesTotal >= 16 && soundLoadTrait.loadState == "loading")
            {
               toggleSoundListeners(sound,false);
               soundLoadTrait.sound = sound;
               updateLoadTrait(soundLoadTrait,"ready");
            }
         };
         var onIOError:* = function(param1:IOErrorEvent, param2:String = null):void
         {
            toggleSoundListeners(sound,false);
            updateLoadTrait(loadTrait,"loadError");
            loadTrait.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(1,!!param1 ? param1.text : param2)));
         };
         var handleSecurityError:* = function(param1:String):void
         {
            toggleSoundListeners(sound,false);
            updateLoadTrait(loadTrait,"loadError");
            loadTrait.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(2,param1)));
         };
         var soundLoadTrait:SoundLoadTrait = loadTrait as SoundLoadTrait;
         updateLoadTrait(soundLoadTrait,"loading");
         sound = new Sound();
         toggleSoundListeners(sound,true);
         urlRequest = new URLRequest((soundLoadTrait.resource as URLResource).url.toString());
         context = new SoundLoaderContext(1000,checkPolicyFile);
         try
         {
            sound.load(urlRequest,context);
         }
         catch(ioError:IOError)
         {
            onIOError(null,ioError.message);
         }
         catch(securityError:SecurityError)
         {
            handleSecurityError(securityError.message);
         }
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         var _loc2_:SoundLoadTrait = param1 as SoundLoadTrait;
         updateLoadTrait(_loc2_,"unloading");
         try
         {
            if(_loc2_.sound != null)
            {
               _loc2_.sound.close();
            }
         }
         catch(error:IOError)
         {
         }
         updateLoadTrait(_loc2_,"uninitialized");
      }
   }
}

