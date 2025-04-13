package it.gotoandplay.smartfoxserver.http
{
   import flash.events.Event;
   
   public class HttpEvent extends Event
   {
      public static const onHttpData:String = "onHttpData";
      
      public static const onHttpError:String = "onHttpError";
      
      public static const onHttpPollError:String = "onHttpPollError";
      
      public static const onHttpConnect:String = "onHttpConnect";
      
      public static const onHttpClose:String = "onHttpClose";
      
      public var params:Object;
      
      private var evtType:String;
      
      public function HttpEvent(param1:String, param2:Object)
      {
         super(param1);
         this.params = param2;
         this.evtType = param1;
      }
      
      override public function clone() : Event
      {
         return new HttpEvent(this.evtType,this.params);
      }
      
      override public function toString() : String
      {
         return formatToString("HttpEvent","type","bubbles","cancelable","eventPhase","params");
      }
   }
}

