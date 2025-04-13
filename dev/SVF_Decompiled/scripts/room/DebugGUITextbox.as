package room
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DebugGUITextbox extends Sprite
   {
      private static const BG_HEADER_COLOR:Number = 0;
      
      private static const BG_COLOR:Number = 6710886;
      
      private static const BG_ALPHA:Number = 0.6;
      
      private static const TXT_FONT:String = "Lucida Console";
      
      private static const TXT_COLOR:Number = 16777215;
      
      private static const TITLE_ROW_HEIGHT:int = 18;
      
      private static const MAX_LINES:int = 500;
      
      private var _parent:DisplayObjectContainer;
      
      private var _titleTextField:TextField;
      
      private var _textField:TextField;
      
      public function DebugGUITextbox(param1:DisplayObjectContainer, param2:String = "", param3:String = "", param4:Boolean = false, param5:Boolean = false, param6:Boolean = true, param7:Number = 800, param8:Number = 18, param9:Boolean = false)
      {
         super();
         var _loc10_:* = param3.length > 0;
         if(param6)
         {
            initBackgroundLayer(param7,param8,_loc10_);
         }
         if(_loc10_)
         {
            initTitleLayer(param3,param7,param6);
         }
         initTextLayer(param2,param7,param8,param5,_loc10_,param9);
         visible = param4;
         updateParent(false,param1);
      }
      
      private function initBackgroundLayer(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc4_:Sprite = new Sprite();
         _loc4_.alpha = 0.6;
         var _loc6_:int = 0;
         var _loc5_:int = param2;
         if(param3)
         {
            _loc6_ += 18;
            _loc5_ -= 18;
         }
         _loc4_.graphics.beginFill(6710886);
         _loc4_.graphics.drawRect(0,_loc6_,param1,_loc5_);
         addChild(_loc4_);
      }
      
      private function initTitleLayer(param1:String, param2:Number, param3:Boolean) : void
      {
         var _loc5_:Sprite = null;
         if(param3)
         {
            _loc5_ = new Sprite();
            _loc5_.alpha = 0.6;
            _loc5_.graphics.beginFill(0);
            _loc5_.graphics.drawRect(0,0,param2,18);
            addChild(_loc5_);
         }
         _titleTextField = new TextField();
         var _loc4_:TextFormat = new TextFormat();
         _loc4_.font = "Lucida Console";
         _loc4_.size = 11;
         _loc4_.bold = true;
         _titleTextField.defaultTextFormat = _loc4_;
         _titleTextField.text = param1;
         _titleTextField.textColor = 16777215;
         _titleTextField.width = param2;
         _titleTextField.height = 18;
         _titleTextField.mouseEnabled = false;
         _titleTextField.selectable = false;
         addChild(_titleTextField);
      }
      
      private function initTextLayer(param1:String, param2:Number, param3:Number, param4:Boolean, param5:Boolean, param6:Boolean) : void
      {
         _textField = new TextField();
         var _loc7_:TextFormat = new TextFormat();
         _loc7_.font = "Lucida Console";
         _loc7_.size = 10;
         _textField.defaultTextFormat = _loc7_;
         _textField.text = param1;
         _textField.textColor = 16777215;
         _textField.width = param2;
         _textField.height = param3;
         if(param5)
         {
            _textField.y = 18;
            _textField.height -= 18;
         }
         if(!param4)
         {
            _textField.mouseEnabled = false;
            _textField.selectable = false;
         }
         else
         {
            addEventListener("mouseDown",stopPropagationMouseEventHandler,false,0,true);
         }
         if(param6)
         {
            _textField.wordWrap = true;
            _textField.multiline = true;
         }
         _textField.useRichTextClipboard = true;
         addChild(_textField);
      }
      
      private function updateParent(param1:Boolean, param2:DisplayObjectContainer = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:* = _parent == null;
         if(param2 && param2 != _parent)
         {
            if(_parent && param1)
            {
               _parent.removeChild(this);
            }
            _parent = param2;
            _loc4_ = true;
         }
         if(_parent)
         {
            if(visible)
            {
               _parent.addChild(this);
            }
            else if(!_loc3_ && !_loc4_)
            {
               _parent.removeChild(this);
            }
         }
      }
      
      public function setVisibility(param1:Boolean, param2:DisplayObjectContainer = null) : void
      {
         var _loc3_:Boolean = visible;
         visible = param1;
         updateParent(visible,param2);
      }
      
      public function toggleVisiblity(param1:DisplayObjectContainer = null) : Boolean
      {
         var _loc2_:Boolean = visible;
         visible = !visible;
         updateParent(_loc2_,param1);
         return visible;
      }
      
      public function get textField() : TextField
      {
         return _textField;
      }
      
      public function get text() : String
      {
         return _textField.text;
      }
      
      public function set text(param1:String) : void
      {
         _textField.text = param1;
      }
      
      public function append(param1:String) : void
      {
         appendToField(param1,false);
      }
      
      public function appendHtml(param1:String) : void
      {
         appendToField(param1,true);
      }
      
      private function appendToField(param1:String, param2:Boolean) : void
      {
         var _loc3_:* = _textField.scrollV == _textField.maxScrollV;
         if(param2)
         {
            _textField.htmlText += param1;
         }
         else
         {
            _textField.text += param1;
         }
         trimLines(param2);
         if(_loc3_)
         {
            textField.scrollV = _textField.maxScrollV;
         }
      }
      
      private function trimLines(param1:Boolean) : void
      {
         while(_textField.numLines > 500)
         {
            if(param1)
            {
               _textField.htmlText = _textField.htmlText.substr(_textField.htmlText.indexOf("</P>") + 4);
            }
            else
            {
               _textField.replaceText(0,_textField.getLineOffset(1) - 1,"");
            }
         }
      }
      
      public function get titleTextField() : TextField
      {
         return _titleTextField;
      }
      
      private function stopPropagationMouseEventHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

