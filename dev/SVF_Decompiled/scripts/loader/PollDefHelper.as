package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.utils.ByteArray;
   
   public class PollDefHelper
   {
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      public function PollDefHelper()
      {
         super();
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get def() : Object
      {
         return _def;
      }
      
      public function init(param1:uint, param2:Function = null) : void
      {
         _id = param1;
         _callback = param2;
         PollFileServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         PollFileServer.instance.requestFile(_id,false,2);
      }
      
      public function destroy() : void
      {
         PollFileServer.instance.removeEventListener("OnNewData",handleData);
         _callback = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:ByteArray = null;
         if(param1.id == _id && param1.success)
         {
            PollFileServer.instance.removeEventListener("OnNewData",handleData);
            if(param1.contentType == 0)
            {
               _def = JSON.parse(param1.data);
            }
            else if(param1.contentType == 2)
            {
               _loc3_ = new ByteArray();
               _loc3_.writeObject(param1.data);
               _loc3_.position = 0;
               _loc2_ = _loc3_.readObject();
               _loc2_.uncompress("deflate");
               _def = _loc2_.readObject();
            }
            else
            {
               _def = param1.data;
            }
            if(_callback != null)
            {
               _callback(this);
               _callback = null;
            }
         }
      }
   }
}

