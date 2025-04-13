package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class FeedbackFileServer extends BaseFileServer
   {
      private static const CONTENT_PATH:String = "feedbackDefs/";
      
      private static var _instance:FeedbackFileServer;
      
      public function FeedbackFileServer(param1:Class)
      {
         super("feedbackDefs/");
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use FeedbackFileServer.instance.");
         }
      }
      
      public static function get instance() : FeedbackFileServer
      {
         if(!_instance)
         {
            _instance = new FeedbackFileServer(SingletonLock);
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
