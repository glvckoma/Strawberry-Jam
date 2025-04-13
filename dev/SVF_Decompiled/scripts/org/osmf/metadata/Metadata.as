package org.osmf.metadata
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.MetadataEvent;
   import org.osmf.utils.OSMFStrings;
   
   public class Metadata extends EventDispatcher
   {
      private var data:Dictionary;
      
      public function Metadata()
      {
         super();
      }
      
      public function getValue(param1:String) : *
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         return data != null ? data[param1] : null;
      }
      
      public function addValue(param1:String, param2:Object) : void
      {
         var _loc4_:Event = null;
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         if(data == null)
         {
            data = new Dictionary();
         }
         var _loc3_:* = data[param1];
         data[param1] = param2;
         if(_loc3_ != param2)
         {
            _loc4_ = _loc3_ === undefined ? new MetadataEvent("valueAdd",false,false,param1,param2) : new MetadataEvent("valueChange",false,false,param1,param2,_loc3_);
            dispatchEvent(_loc4_);
         }
      }
      
      public function removeValue(param1:String) : *
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         var _loc2_:* = data[param1];
         if(_loc2_ !== undefined)
         {
            delete data[param1];
            dispatchEvent(new MetadataEvent("valueRemove",false,false,param1,_loc2_));
         }
         return _loc2_;
      }
      
      public function get keys() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         if(data != null)
         {
            for(var _loc2_ in data)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function get synthesizer() : MetadataSynthesizer
      {
         return null;
      }
   }
}

