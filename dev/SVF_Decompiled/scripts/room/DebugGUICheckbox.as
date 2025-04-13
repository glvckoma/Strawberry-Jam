package room
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DebugGUICheckbox extends Sprite
   {
      private static const BOX_COLOR:Number = 16777215;
      
      private static const CHK_COLOR:Number = 0;
      
      private static const CHKBOX_WIDTH:Number = 20;
      
      private static const CHKBOX_HEIGHT:Number = 20;
      
      private var _box:Sprite;
      
      private var _check:Sprite;
      
      private var _label:TextField;
      
      private var _visible:Boolean;
      
      public var valueChangedCallback:Function;
      
      public function DebugGUICheckbox()
      {
         super();
      }
      
      public function init(param1:DisplayObjectContainer, param2:Function, param3:String, param4:Boolean = false, param5:Boolean = false) : void
      {
         var initParent:DisplayObjectContainer = param1;
         var initValueChangedCallback:Function = param2;
         var initLabel:String = param3;
         var initChecked:Boolean = param4;
         var initVisible:Boolean = param5;
         _box = new Sprite();
         _check = new Sprite();
         with(_box.graphics)
         {
            beginFill(BOX_COLOR);
            drawRect(0,0,CHKBOX_WIDTH,CHKBOX_HEIGHT);
            endFill();
         }
         with(_check.graphics)
         {
            lineStyle(2,CHK_COLOR);
            moveTo(0,0);
            lineTo(CHKBOX_WIDTH,CHKBOX_HEIGHT);
         }
         addEventListener("mouseDown",chkboxMouseDownHandler,false,0,true);
         _box.addChild(_check);
         addChild(_box);
         _label = new TextField();
         _label.x = 20;
         _label.height = 20;
         _label.text = initLabel;
         _label.selectable = false;
         addChild(_label);
         _check.visible = initChecked;
         visible = initVisible;
         valueChangedCallback = initValueChangedCallback;
         initParent.addChild(this);
      }
      
      public function get checked() : Boolean
      {
         return _check.visible;
      }
      
      public function set checked(param1:Boolean) : void
      {
         _check.visible = param1;
      }
      
      public function get label() : TextField
      {
         return _label;
      }
      
      public function toggleVisiblity() : void
      {
         visible = !visible;
      }
      
      public function toggleChecked() : void
      {
         _check.visible = !_check.visible;
      }
      
      private function chkboxMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _check.visible = !_check.visible;
         if(valueChangedCallback != null)
         {
            valueChangedCallback(_check.visible);
         }
      }
   }
}

