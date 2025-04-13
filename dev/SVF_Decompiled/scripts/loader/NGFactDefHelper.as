package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.utils.ByteArray;
   
   public class NGFactDefHelper
   {
      private var _id:uint;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      public function NGFactDefHelper()
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
      
      public function init(param1:uint, param2:Function = null, param3:Object = null) : void
      {
         _id = param1;
         _callback = param2;
         _passback = param3;
         NGFactFileServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         NGFactFileServer.instance.requestFile(_id);
      }
      
      public function destroy() : void
      {
         NGFactFileServer.instance.removeEventListener("OnNewData",handleData);
         _callback = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         var _loc2_:* = undefined;
         var _loc3_:ByteArray = null;
         if(param1.id == _id && param1.success)
         {
            NGFactFileServer.instance.removeEventListener("OnNewData",handleData);
            _loc3_ = new ByteArray();
            _loc3_.writeObject(param1.data);
            _loc3_.position = 0;
            _loc2_ = _loc3_.readObject();
            _loc2_.uncompress("deflate");
            _def = _loc2_.readObject();
            if(_passback != null)
            {
               _def.passback = _passback;
               _passback = null;
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

