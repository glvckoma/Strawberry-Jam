package org.osmf.net.httpstreaming.flv
{
   public class FLVTagScriptDataObject extends FLVTag
   {
      public function FLVTagScriptDataObject(param1:int = 18)
      {
         super(param1);
      }
      
      public function get objects() : Array
      {
         var _loc1_:Array = [];
         bytes.position = 11;
         while(bytes.bytesAvailable)
         {
            _loc1_.push(bytes.readObject());
         }
         return _loc1_;
      }
      
      public function set objects(param1:Array) : void
      {
         bytes.objectEncoding = 0;
         bytes.length = 11;
         bytes.position = 11;
         for each(var _loc2_ in param1)
         {
            bytes.writeObject(_loc2_);
         }
         dataSize = bytes.length - 11;
      }
   }
}

