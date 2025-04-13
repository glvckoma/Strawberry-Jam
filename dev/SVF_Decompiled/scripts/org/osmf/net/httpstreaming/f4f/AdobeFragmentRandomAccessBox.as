package org.osmf.net.httpstreaming.f4f
{
   internal class AdobeFragmentRandomAccessBox extends FullBox
   {
      private var _timeScale:uint;
      
      private var _localRandomAccessEntries:Vector.<LocalRandomAccessEntry>;
      
      private var _globalRandomAccessEntries:Vector.<GlobalRandomAccessEntry>;
      
      public function AdobeFragmentRandomAccessBox()
      {
         super();
      }
      
      public function get timeScale() : uint
      {
         return _timeScale;
      }
      
      public function set timeScale(param1:uint) : void
      {
         _timeScale = param1;
      }
      
      public function get localRandomAccessEntries() : Vector.<LocalRandomAccessEntry>
      {
         return _localRandomAccessEntries;
      }
      
      public function set localRandomAccessEntries(param1:Vector.<LocalRandomAccessEntry>) : void
      {
         _localRandomAccessEntries = param1;
      }
      
      public function get globalRandomAccessEntries() : Vector.<GlobalRandomAccessEntry>
      {
         return _globalRandomAccessEntries;
      }
      
      public function set globalRandomAccessEntries(param1:Vector.<GlobalRandomAccessEntry>) : void
      {
         _globalRandomAccessEntries = param1;
      }
      
      public function findNearestKeyFrameOffset(param1:Number) : LocalRandomAccessEntry
      {
         var _loc2_:LocalRandomAccessEntry = null;
         var _loc3_:int = _localRandomAccessEntries.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = _localRandomAccessEntries[_loc3_];
            if(_loc2_.time <= param1)
            {
               return _loc2_;
            }
            _loc3_--;
         }
         return null;
      }
   }
}

