package org.osmf.traits
{
   import flash.display.DisplayObject;
   import org.osmf.events.DisplayObjectEvent;
   
   public class DisplayObjectTrait extends MediaTraitBase
   {
      private var _displayObject:DisplayObject;
      
      private var _mediaWidth:Number = 0;
      
      private var _mediaHeight:Number = 0;
      
      public function DisplayObjectTrait(param1:DisplayObject, param2:Number = 0, param3:Number = 0)
      {
         super("displayObject");
         _displayObject = param1;
         _mediaWidth = param2;
         _mediaHeight = param3;
      }
      
      public function get displayObject() : DisplayObject
      {
         return _displayObject;
      }
      
      public function get mediaWidth() : Number
      {
         return _mediaWidth;
      }
      
      public function get mediaHeight() : Number
      {
         return _mediaHeight;
      }
      
      final protected function setDisplayObject(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObject = null;
         if(_displayObject != param1)
         {
            displayObjectChangeStart(param1);
            _loc2_ = _displayObject;
            _displayObject = param1;
            displayObjectChangeEnd(_loc2_);
         }
      }
      
      final protected function setMediaSize(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(param1 != _mediaWidth || param2 != _mediaHeight)
         {
            mediaSizeChangeStart(param1,param2);
            _loc3_ = _mediaWidth;
            _loc4_ = _mediaHeight;
            _mediaWidth = param1;
            _mediaHeight = param2;
            mediaSizeChangeEnd(_loc3_,_loc4_);
         }
      }
      
      protected function displayObjectChangeStart(param1:DisplayObject) : void
      {
      }
      
      protected function displayObjectChangeEnd(param1:DisplayObject) : void
      {
         dispatchEvent(new DisplayObjectEvent("displayObjectChange",false,false,param1,_displayObject));
      }
      
      protected function mediaSizeChangeStart(param1:Number, param2:Number) : void
      {
      }
      
      protected function mediaSizeChangeEnd(param1:Number, param2:Number) : void
      {
         dispatchEvent(new DisplayObjectEvent("mediaSizeChange",false,false,null,null,param1,param2,_mediaWidth,_mediaHeight));
      }
   }
}

