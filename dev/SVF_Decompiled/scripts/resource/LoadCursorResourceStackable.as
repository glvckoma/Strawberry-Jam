package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.ui.Mouse;
   import gui.CursorManager;
   
   public class LoadCursorResourceStackable implements IResourceStackable
   {
      public function LoadCursorResourceStackable()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         if(Mouse["supportsNativeCursor"])
         {
            CursorManager.init();
         }
         param1(this);
      }
   }
}

