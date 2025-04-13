package gui
{
   public class GuiSoundBtnExit extends GuiSoundButton
   {
      public function GuiSoundBtnExit()
      {
         super();
      }
      
      override public function playClickSound() : void
      {
         AJAudio.playExitBtnClick();
      }
      
      override public function playRolloverSound() : void
      {
         AJAudio.playExitBtnRollover();
      }
   }
}

