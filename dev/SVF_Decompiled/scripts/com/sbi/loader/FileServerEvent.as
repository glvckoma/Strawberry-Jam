package com.sbi.loader
{
   import flash.events.Event;
   
   public class FileServerEvent extends Event
   {
      public static const ON_NEW_DATA:String = "OnNewData";
      
      public static const JSON_TYPE:int = 0;
      
      public static const PLAIN_TEXT_TYPE:int = 1;
      
      public static const AMF3_TYPE:int = 2;
      
      public var id:Object;
      
      public var data:*;
      
      public var success:Boolean = true;
      
      public var contentType:int = 0;
      
      public function FileServerEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new FileServerEvent(type);
      }
   }
}

