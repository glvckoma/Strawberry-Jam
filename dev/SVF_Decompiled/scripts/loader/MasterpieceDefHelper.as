package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class MasterpieceDefHelper
   {
      private var _id:String;
      
      private var _def:Object;
      
      private var _callback:Function;
      
      private var _loader:Loader;
      
      private var _image:Sprite;
      
      public function MasterpieceDefHelper()
      {
         super();
      }
      
      public function init(param1:String, param2:Function = null) : void
      {
         _id = param1;
         _callback = param2;
         _loader = new Loader();
         MasterpieceFileServer.instance.addEventListener("OnNewData",handleData,false,0,true);
         MasterpieceFileServer.instance.requestFile(_id);
      }
      
      public function destroy() : void
      {
         MasterpieceFileServer.instance.removeEventListener("OnNewData",handleData);
         _callback = null;
         _loader = null;
         _image = null;
      }
      
      private function handleData(param1:FileServerEvent) : void
      {
         if(param1.id == _id && param1.success)
         {
            MasterpieceFileServer.instance.removeEventListener("OnNewData",handleData);
            _loader.contentLoaderInfo.addEventListener("complete",onBytesLoaded);
            _loader.loadBytes(param1.data);
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _image = new Sprite();
         _image.addChild(_loc2_.content);
         param1.target.removeEventListener("complete",onBytesLoaded);
         if(_callback != null)
         {
            _callback(_image);
            _callback = null;
         }
      }
   }
}

