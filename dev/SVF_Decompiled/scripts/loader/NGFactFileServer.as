package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class NGFactFileServer extends BaseFileServer
   {
      private static const CONTENT_PATH:String = "factDefs/";
      
      private static var _instance:NGFactFileServer;
      
      public function NGFactFileServer(param1:Class)
      {
         super("factDefs/");
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use NGFactFileServer.instance.");
         }
      }
      
      public static function get instance() : NGFactFileServer
      {
         if(!_instance)
         {
            _instance = new NGFactFileServer(SingletonLock);
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
