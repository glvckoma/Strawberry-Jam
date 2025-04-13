package loader
{
   import com.sbi.loader.BaseFileServer;
   
   public class MasterpieceFileServer extends BaseFileServer
   {
      private static const CONTENT_PATH:String = "masterpieces/";
      
      private static var _instance:MasterpieceFileServer;
      
      public function MasterpieceFileServer(param1:Class)
      {
         super("masterpieces/");
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use MasterpieceFileServer.instance.");
         }
      }
      
      public static function get instance() : MasterpieceFileServer
      {
         if(!_instance)
         {
            _instance = new MasterpieceFileServer(SingletonLock);
         }
         return _instance;
      }
      
      override public function requestFile(param1:Object, param2:Boolean = false, param3:int = 0, param4:Boolean = false, param5:Function = null) : void
      {
         super.requestFile(param1,param2,param3,false,param5);
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
