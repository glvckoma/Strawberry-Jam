package gui
{
   import flash.display.MovieClip;
   
   public class GuiStatusIcon
   {
      public function GuiStatusIcon()
      {
         super();
      }
      
      public static function initClip(param1:MovieClip, param2:Object = null) : void
      {
         param1.visible = false;
         param1["_x"].visible = false;
         param1["_wait"].visible = true;
         param1["_check"].visible = false;
         if(param2)
         {
            param2.xTracking = false;
            param2.waitTracking = true;
            param2.checkTracking = false;
         }
      }
      
      public static function initClipOff(param1:MovieClip, param2:Object = null) : void
      {
         param1.visible = false;
         param1["_x"].visible = false;
         param1["_wait"].visible = false;
         param1["_check"].visible = false;
         if(param2)
         {
            param2.xTracking = false;
            param2.waitTracking = false;
            param2.checkTracking = false;
         }
      }
      
      public static function setVisBasedOnTrackers(param1:MovieClip, param2:Object = null) : void
      {
         param1["_x"].visible = param2.xTracking;
         param1["_wait"].visible = param2.waitTracking;
         param1["_check"].visible = param2.checkTracking;
      }
      
      public static function showX(param1:MovieClip, param2:Object = null) : void
      {
         param1["_x"].visible = true;
         param1["_wait"].visible = false;
         param1["_check"].visible = false;
         if(param2)
         {
            param2.xTracking = true;
            param2.waitTracking = false;
            param2.checkTracking = false;
         }
      }
      
      public static function showWait(param1:MovieClip, param2:Object = null) : void
      {
         param1["_x"].visible = false;
         param1["_wait"].visible = true;
         param1["_check"].visible = false;
         if(param2)
         {
            param2.xTracking = false;
            param2.waitTracking = true;
            param2.checkTracking = false;
         }
      }
      
      public static function showCheck(param1:MovieClip, param2:Object = null) : void
      {
         param1["_x"].visible = false;
         param1["_wait"].visible = false;
         param1["_check"].visible = true;
         if(param2)
         {
            param2.xTracking = false;
            param2.waitTracking = false;
            param2.checkTracking = true;
         }
      }
   }
}

