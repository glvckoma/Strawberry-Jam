package com.sbi.loader
{
   import flash.events.Event;
   
   public class ImageServerEvent extends Event
   {
      public static const ON_NEW_DATA:String = "OnNewData";
      
      public static const ON_GLOBAL_PALETTE:String = "OnGlobalPalette";
      
      public var id:uint;
      
      public var layer:int;
      
      public var imageData:*;
      
      public var versionNum:int;
      
      public var genericData:*;
      
      public var frames:int;
      
      public var success:Boolean = true;
      
      public function ImageServerEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         var _loc1_:ImageServerEvent = new ImageServerEvent(type);
         _loc1_.id = id;
         _loc1_.layer = layer;
         _loc1_.imageData = imageData;
         _loc1_.versionNum = versionNum;
         _loc1_.genericData = genericData;
         _loc1_.frames = frames;
         _loc1_.success = success;
         return _loc1_;
      }
   }
}

