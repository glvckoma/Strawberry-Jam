package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class LoaderEvent extends Event
   {
      public static const LOAD_STATE_CHANGE:String = "loadStateChange";
      
      private var _loader:LoaderBase;
      
      private var _loadTrait:LoadTrait;
      
      private var _oldState:String;
      
      private var _newState:String;
      
      public function LoaderEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:LoaderBase = null, param5:LoadTrait = null, param6:String = null, param7:String = null)
      {
         super(param1,param2,param3);
         _loader = param4;
         _loadTrait = param5;
         _oldState = param6;
         _newState = param7;
      }
      
      public function get loader() : LoaderBase
      {
         return _loader;
      }
      
      public function get loadTrait() : LoadTrait
      {
         return _loadTrait;
      }
      
      public function get oldState() : String
      {
         return _oldState;
      }
      
      public function get newState() : String
      {
         return _newState;
      }
      
      override public function clone() : Event
      {
         return new LoaderEvent(type,bubbles,cancelable,loader,loadTrait,oldState,newState);
      }
   }
}

