package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class PollFileServer extends BaseFileServer
   {
      private static const CONTENT_PATH:String = "pollDefs/";
      
      private static var _instance:PollFileServer;
      
      public function PollFileServer(param1:Class)
      {
         super("pollDefs/");
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use PollItemServer.instance.");
         }
      }
      
      public static function get instance() : PollFileServer
      {
         if(!_instance)
         {
            _instance = new PollFileServer(SingletonLock);
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
