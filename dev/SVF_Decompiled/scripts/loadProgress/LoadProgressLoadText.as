package loadProgress
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import localization.LocalizationManager;
   
   public class LoadProgressLoadText extends MovieClip
   {
      private var _loadText:MovieClip;
      
      private var _loadStatus0:Array = [6652,15751,15752,15753,15754,15755,15756,15757,15758,15759,15761,15762,15763,15765,15766,15767,15768,15769,15770,15771,15772];
      
      private var _loadStatus1:Array = [31552,31553,31554,31555,31556,31557,31558,31559,31560,31561,31562,31563,31564,31565,31566,31567,31568,31569,31570,31571,31572,31573,31574,31575,31576,31577,31578,31579,31580,31581,31582,31583,31584,31585,31586,31587,31588,32631,32632];
      
      private var _frameCounter:int = 1;
      
      private var _currentText:int = 0;
      
      private var _holdTime:int;
      
      private var _holdOn:Boolean = false;
      
      private var _lptb:LoadProgressTextBox;
      
      public function LoadProgressLoadText(param1:MovieClip, param2:LoadProgressTextBox)
      {
         super();
         _loadText = param1;
         _lptb = param2;
         gMainFrame.stage.addEventListener("enterFrame",changeText,false,0,true);
         _currentText = Math.floor(Math.random() * this["_loadStatus" + _lptb.headingNum].length);
         localizeTextBox();
      }
      
      public function destroy() : void
      {
         gMainFrame.stage.removeEventListener("enterFrame",changeText);
         _loadStatus0 = null;
         _loadStatus1 = null;
         _loadText = null;
      }
      
      public function changeText(param1:Event) : void
      {
         if(!_holdOn)
         {
            _holdTime = Math.ceil(Math.random() * 50) + 50;
            _holdOn = true;
         }
         if(_frameCounter >= _holdTime)
         {
            localizeTextBox();
            _frameCounter = 1;
            _currentText++;
            if(_currentText >= this["_loadStatus" + _lptb.headingNum].length)
            {
               _currentText = 0;
            }
            _holdOn = false;
         }
         _frameCounter++;
      }
      
      public function localizeTextBox() : void
      {
         if(LocalizationManager.hasLocalizations)
         {
            LocalizationManager.translateId(_loadText.textBox,this["_loadStatus" + _lptb.headingNum][_currentText]);
            _loadText.textBox.visible = true;
         }
         else
         {
            _loadText.textBox.visible = false;
         }
      }
   }
}

