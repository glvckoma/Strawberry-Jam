package avatar
{
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import gui.DarkenManager;
   import gui.GuiManager;
   
   public class NewWorldAvatar implements INewAvatar
   {
      public function NewWorldAvatar()
      {
         super();
      }
      
      public function screenInitCallback(param1:MovieClip) : void
      {
         param1.visible = false;
      }
      
      public function get playSound() : Boolean
      {
         return false;
      }
      
      public function newAvatarData(param1:int, param2:String, param3:Array, param4:Function, param5:int = -1, param6:int = -1, param7:Boolean = false) : void
      {
         SBTracker.trackPageview("/game/play/popup/avatarSwitch/buyAnimal");
         var _loc8_:Boolean = param2 && param2 != "";
         if(_loc8_)
         {
            AvatarSwitch.addNewWorldAvatar(param1,param2,param3,param5,param6,param7);
         }
         if(param4 != null && !AvatarSwitch.isAddingSlot && !param7)
         {
            param4(_loc8_);
         }
         if(_loc8_)
         {
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public function hideConnectingMsg() : void
      {
      }
      
      public function nameTypeScreenDone() : void
      {
         GuiManager.closeAvatarCreator();
      }
      
      public function logInForCreateAvatarData() : void
      {
      }
   }
}

