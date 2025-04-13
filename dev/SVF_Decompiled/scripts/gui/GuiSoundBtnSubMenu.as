package gui
{
   public class GuiSoundBtnSubMenu extends GuiSoundButton
   {
      public function GuiSoundBtnSubMenu()
      {
         super();
      }
      
      override public function playClickSound() : void
      {
         if(AJAudio)
         {
            AJAudio.playSubMenuBtnClick();
         }
      }
      
      override public function playRolloverSound() : void
      {
         if(AJAudio)
         {
            AJAudio.playSubMenuBtnRollover();
         }
      }
   }
}

