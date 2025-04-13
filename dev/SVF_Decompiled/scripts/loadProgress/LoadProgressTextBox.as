package loadProgress
{
   import flash.display.MovieClip;
   import localization.LocalizationManager;
   
   public class LoadProgressTextBox extends MovieClip
   {
      private var _textBox:MovieClip;
      
      private var _headings:Array = new Array(6654,15774);
      
      private var _messages:Array = new Array(31589,31590,31591,31592,31593,31594,31595,31596,31597,31598,31599,31600,31601,31602,31603,31604,31605,31606,31607,31608,31609,31610,31611,31612,31613,31614);
      
      private var _headingNum:int = 0;
      
      private var _textNum:int = 0;
      
      public function LoadProgressTextBox(param1:MovieClip)
      {
         super();
         _textBox = param1;
      }
      
      public function destroy() : void
      {
         _headings = null;
         _messages = null;
         _textBox = null;
      }
      
      public function get headingNum() : int
      {
         return _headingNum;
      }
      
      public function displayText(param1:Boolean = false) : void
      {
         if(param1 == false)
         {
            if(_textNum >= _messages.length && _headingNum == 0)
            {
               _textNum = 0;
               _headingNum = 1;
               _textBox.paw.visible = false;
            }
            if(_textNum >= _messages.length && _headingNum == 1)
            {
               _textNum = 0;
               _headingNum = 0;
               _textBox.paw.visible = true;
            }
         }
         else
         {
            _headingNum = Math.floor(Math.random() * 2);
            _textNum = Math.floor(Math.random() * 5);
            _textBox.paw.visible = _headingNum == 0;
         }
         if(LocalizationManager.hasLocalizations)
         {
            LocalizationManager.translateId(_textBox.messageText,_messages[_textNum]);
            LocalizationManager.translateId(_textBox.headingText,_headings[_headingNum]);
            _textBox.messageText.visible = true;
            _textBox.headingText.visible = true;
         }
         else
         {
            _textBox.messageText.visible = false;
            _textBox.headingText.visible = false;
         }
         _textNum++;
      }
   }
}

