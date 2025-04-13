package libraries.uanalytics.tracking
{
   public class RateLimitError extends Error
   {
      public function RateLimitError(param1:String = "", param2:int = 0)
      {
         super(param1,param2);
         this.name = "RateLimitError";
      }
   }
}

