package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.events.Event;
   
   public class BaseResourceStackable implements IResourceStackable
   {
      protected var _resourceDoneLoadingCallback:Function;
      
      public function BaseResourceStackable()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         _resourceDoneLoadingCallback = param1;
      }
      
      protected function resourceLoadCompleteHandler(param1:Event) : void
      {
         _resourceDoneLoadingCallback(this);
         _resourceDoneLoadingCallback = null;
      }
   }
}

