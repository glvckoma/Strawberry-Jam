package org.osmf.traits
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.media.MediaElement;
   
   public class TraitEventDispatcher extends EventDispatcher
   {
      private static var eventMaps:Dictionary;
      
      private var _mediaElement:MediaElement;
      
      public function TraitEventDispatcher()
      {
         super();
         if(eventMaps == null)
         {
            eventMaps = new Dictionary();
            eventMaps["durationChange"] = "time";
            eventMaps["complete"] = "time";
            eventMaps["playStateChange"] = "play";
            eventMaps["canPauseChange"] = "play";
            eventMaps["volumeChange"] = "audio";
            eventMaps["mutedChange"] = "audio";
            eventMaps["panChange"] = "audio";
            eventMaps["seekingChange"] = "seek";
            eventMaps["switchingChange"] = "dynamicStream";
            eventMaps["autoSwitchChange"] = "dynamicStream";
            eventMaps["numDynamicStreamsChange"] = "dynamicStream";
            eventMaps["displayObjectChange"] = "displayObject";
            eventMaps["mediaSizeChange"] = "displayObject";
            eventMaps["loadStateChange"] = "load";
            eventMaps["bytesLoadedChange"] = "load";
            eventMaps["bytesTotalChange"] = "load";
            eventMaps["bufferingChange"] = "buffer";
            eventMaps["bufferTimeChange"] = "buffer";
            eventMaps["bufferLengthChange"] = "buffer";
            eventMaps["drmStateChange"] = "drm";
            eventMaps["isRecordingChange"] = "dvr";
         }
      }
      
      public function get media() : MediaElement
      {
         return _mediaElement;
      }
      
      public function set media(param1:MediaElement) : void
      {
         var _loc2_:* = null;
         if(param1 != _mediaElement)
         {
            if(_mediaElement != null)
            {
               _mediaElement.removeEventListener("traitAdd",onTraitAdd);
               _mediaElement.removeEventListener("traitRemove",onTraitRemove);
               for each(_loc2_ in _mediaElement.traitTypes)
               {
                  onTraitChanged(_loc2_,false);
               }
            }
            _mediaElement = param1;
            if(_mediaElement != null)
            {
               _mediaElement.addEventListener("traitAdd",onTraitAdd);
               _mediaElement.addEventListener("traitRemove",onTraitRemove);
               for each(_loc2_ in _mediaElement.traitTypes)
               {
                  onTraitChanged(_loc2_,true);
               }
            }
         }
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         var _loc6_:Boolean = hasEventListener(param1);
         super.addEventListener(param1,param2,param3,param4,param5);
         if(_mediaElement && !_loc6_ && eventMaps[param1] != undefined)
         {
            changeListeners(true,eventMaps[param1],param1);
         }
      }
      
      override public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         super.removeEventListener(param1,param2,param3);
         if(_mediaElement && !hasEventListener(param1) && eventMaps[param1] != undefined)
         {
            changeListeners(false,eventMaps[param1],param1);
         }
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         onTraitChanged(param1.traitType,true);
      }
      
      private function onTraitRemove(param1:MediaElementEvent) : void
      {
         onTraitChanged(param1.traitType,false);
      }
      
      private function onTraitChanged(param1:String, param2:Boolean) : void
      {
         switch(param1)
         {
            case "time":
               changeListeners(param2,param1,"durationChange");
               changeListeners(param2,param1,"complete");
               break;
            case "play":
               changeListeners(param2,param1,"playStateChange");
               changeListeners(param2,param1,"canPauseChange");
               break;
            case "audio":
               changeListeners(param2,param1,"volumeChange");
               changeListeners(param2,param1,"mutedChange");
               changeListeners(param2,param1,"panChange");
               break;
            case "seek":
               changeListeners(param2,param1,"seekingChange");
               break;
            case "dynamicStream":
               changeListeners(param2,param1,"switchingChange");
               changeListeners(param2,param1,"autoSwitchChange");
               changeListeners(param2,param1,"numDynamicStreamsChange");
               break;
            case "displayObject":
               changeListeners(param2,param1,"displayObjectChange");
               changeListeners(param2,param1,"mediaSizeChange");
               break;
            case "load":
               changeListeners(param2,param1,"loadStateChange");
               changeListeners(param2,param1,"bytesTotalChange");
               changeListeners(param2,param1,"bytesLoadedChange");
               break;
            case "buffer":
               changeListeners(param2,param1,"bufferingChange");
               changeListeners(param2,param1,"bufferTimeChange");
               changeListeners(param2,param1,"bufferLengthChange");
               break;
            case "drm":
               changeListeners(param2,param1,"drmStateChange");
               break;
            case "dvr":
               changeListeners(param2,param1,"isRecordingChange");
         }
      }
      
      private function changeListeners(param1:Boolean, param2:String, param3:String) : void
      {
         if(_mediaElement.getTrait(param2) != null)
         {
            if(param1 && hasEventListener(param3))
            {
               _mediaElement.getTrait(param2).addEventListener(param3,redispatchEvent);
            }
            else
            {
               _mediaElement.getTrait(param2).removeEventListener(param3,redispatchEvent);
            }
         }
      }
      
      private function redispatchEvent(param1:Event) : void
      {
         dispatchEvent(param1.clone());
      }
   }
}

