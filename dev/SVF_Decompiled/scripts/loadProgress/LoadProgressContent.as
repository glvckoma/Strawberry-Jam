package loadProgress
{
   import flash.display.MovieClip;
   
   public class LoadProgressContent extends MovieClip
   {
      private var _content:MovieClip;
      
      private var _textBox:LoadProgressTextBox;
      
      private var _loadText:LoadProgressLoadText;
      
      public function LoadProgressContent(param1:MovieClip)
      {
         super();
         _content = param1;
         _textBox = new LoadProgressTextBox(param1.textBox);
         _loadText = new LoadProgressLoadText(param1.loadText,_textBox);
         _content.loadPercentage.textBox.visible = false;
      }
      
      public function get textBox() : LoadProgressTextBox
      {
         return _textBox;
      }
      
      public function get loadText() : LoadProgressLoadText
      {
         return _loadText;
      }
      
      public function set loadPercentage(param1:Number) : void
      {
         _content.loadPercentage.textBox.text = param1 + "%";
      }
      
      public function set loadPercentageVisibility(param1:Boolean) : void
      {
         _content.loadPercentage.textBox.visible = param1;
         if(param1)
         {
            _content.loadPercentage.textBox.text = "0%";
         }
      }
      
      public function showScreen(param1:Boolean = true) : void
      {
         _content.gotoAndStop(Math.ceil(Math.random() * 4));
         if(_loadText != null)
         {
            _textBox.destroy();
            _loadText.destroy();
         }
         _textBox = new LoadProgressTextBox(_content.textBox);
         _loadText = new LoadProgressLoadText(_content.loadText,_textBox);
         if(param1)
         {
            _textBox.displayText(true);
            _textBox.visible = true;
         }
         else
         {
            _textBox.visible = false;
         }
      }
      
      public function destroyScreens() : void
      {
         if(_loadText != null)
         {
            _textBox.destroy();
            _loadText.destroy();
            _textBox = null;
            _loadText = null;
         }
      }
      
      public function setProgress(param1:int) : void
      {
         _content.loadBar.gotoAndStop(param1 + 1);
      }
      
      public function updateText() : void
      {
         if(_textBox)
         {
            _textBox.displayText();
         }
         if(_loadText)
         {
            _loadText.localizeTextBox();
         }
      }
   }
}

