package org.osmf.media
{
   import org.osmf.utils.OSMFStrings;
   
   public class MediaFactoryItem
   {
      private var _id:String;
      
      private var _canHandleResourceFunction:Function;
      
      private var _mediaElementCreationFunction:Function;
      
      private var _type:String;
      
      public function MediaFactoryItem(param1:String, param2:Function, param3:Function, param4:String = null)
      {
         super();
         if(param1 == null || param2 == null || param3 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         if(!param4)
         {
            param4 = "standard";
         }
         _id = param1;
         _canHandleResourceFunction = param2;
         _mediaElementCreationFunction = param3;
         _type = param4;
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function get canHandleResourceFunction() : Function
      {
         return _canHandleResourceFunction;
      }
      
      public function get mediaElementCreationFunction() : Function
      {
         return _mediaElementCreationFunction;
      }
      
      public function get type() : String
      {
         return _type;
      }
   }
}

