package com.sbi.loader
{
   import flash.events.Event;
   
   public class LoaderEvent extends Event
   {
      public static const ON_LOAD_COMPLETE:String = "OnLoadComplete";
      
      public static const ON_LOAD_PROGRESS:String = "OnLoadProgress";
      
      public var status:Boolean;
      
      public var entry:LoaderCacheEntry_Base;
      
      public var message:String;
      
      public var percent:Number;
      
      public function LoaderEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new LoaderEvent(type);
      }
   }
}

