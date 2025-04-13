package org.osmf.net
{
   import org.osmf.utils.OSMFStrings;
   
   public class DynamicStreamingResource extends StreamingURLResource
   {
      private var _streamItems:Vector.<DynamicStreamingItem>;
      
      private var _initialIndex:int;
      
      public function DynamicStreamingResource(param1:String, param2:String = null)
      {
         super(param1,param2);
         _initialIndex = 0;
      }
      
      public function get host() : String
      {
         return url;
      }
      
      public function get streamItems() : Vector.<DynamicStreamingItem>
      {
         if(_streamItems == null)
         {
            _streamItems = new Vector.<DynamicStreamingItem>();
         }
         return _streamItems;
      }
      
      public function set streamItems(param1:Vector.<DynamicStreamingItem>) : void
      {
         _streamItems = param1;
         if(param1 != null)
         {
            param1.sort(compareStreamItems);
         }
      }
      
      public function get initialIndex() : int
      {
         return _initialIndex;
      }
      
      public function set initialIndex(param1:int) : void
      {
         if(_streamItems == null || param1 >= _streamItems.length)
         {
            throw new RangeError(OSMFStrings.getString("invalidParam"));
         }
         _initialIndex = param1;
      }
      
      internal function indexFromName(param1:String) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _streamItems.length)
         {
            if(_streamItems[_loc2_].streamName.indexOf(param1) == 0 || _streamItems[_loc2_].streamName.indexOf("mp4:" + param1) == 0)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function compareStreamItems(param1:DynamicStreamingItem, param2:DynamicStreamingItem) : Number
      {
         var _loc3_:Number = -1;
         if(param1.bitrate == param2.bitrate)
         {
            _loc3_ = 0;
         }
         else if(param1.bitrate > param2.bitrate)
         {
            _loc3_ = 1;
         }
         return _loc3_;
      }
   }
}

