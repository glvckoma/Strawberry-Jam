package org.osmf.events
{
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class DisplayObjectEvent extends Event
   {
      public static const DISPLAY_OBJECT_CHANGE:String = "displayObjectChange";
      
      public static const MEDIA_SIZE_CHANGE:String = "mediaSizeChange";
      
      private var _oldDisplayObject:DisplayObject;
      
      private var _newDisplayObject:DisplayObject;
      
      private var _oldWidth:Number;
      
      private var _oldHeight:Number;
      
      private var _newWidth:Number;
      
      private var _newHeight:Number;
      
      public function DisplayObjectEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:DisplayObject = null, param5:DisplayObject = null, param6:Number = NaN, param7:Number = NaN, param8:Number = NaN, param9:Number = NaN)
      {
         super(param1,param2,param3);
         _oldDisplayObject = param4;
         _newDisplayObject = param5;
         _oldWidth = param6;
         _oldHeight = param7;
         _newWidth = param8;
         _newHeight = param9;
      }
      
      public function get oldDisplayObject() : DisplayObject
      {
         return _oldDisplayObject;
      }
      
      public function get newDisplayObject() : DisplayObject
      {
         return _newDisplayObject;
      }
      
      public function get oldWidth() : Number
      {
         return _oldWidth;
      }
      
      public function get oldHeight() : Number
      {
         return _oldHeight;
      }
      
      public function get newWidth() : Number
      {
         return _newWidth;
      }
      
      public function get newHeight() : Number
      {
         return _newHeight;
      }
      
      override public function clone() : Event
      {
         return new DisplayObjectEvent(type,bubbles,cancelable,_oldDisplayObject,_newDisplayObject,_oldWidth,_oldHeight,_newWidth,_newHeight);
      }
   }
}

