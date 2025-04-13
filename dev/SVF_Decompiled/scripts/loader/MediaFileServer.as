package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class MediaFileServer extends BaseFileServer
   {
      private static const CONTENT_PATH:String = "media/";
      
      private static var _instance:MediaFileServer;
      
      public function MediaFileServer(param1:Class)
      {
         super("media/");
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use MediaFileServer.instance.");
         }
      }
      
      public static function get instance() : MediaFileServer
      {
         if(!_instance)
         {
            _instance = new MediaFileServer(SingletonLock);
         }
         return _instance;
      }
   }
}

class SingletonLock
{
   public function SingletonLock()
   {
      super();
   }
}
