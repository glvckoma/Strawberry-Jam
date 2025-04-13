package room
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DebugGUISlider
   {
      private static const SLIDER_X:Number = 400;
      
      private static const SLIDER_Y:Number = 200;
      
      private static const NUB_COLOR:Number = 16776960;
      
      private static const NUB_WIDTH:Number = 10;
      
      private static const NUB_HEIGHT:Number = 20;
      
      private static const SLIDER_WIDTH:Number = 120;
      
      private static const SLIDER_MAX:Number = 1;
      
      private static const SLIDER_INIT:Number = 1;
      
      private var _drag:Boolean;
      
      private var _slider:Sprite;
      
      private var _nub:Sprite;
      
      private var _value:TextField;
      
      private var _visible:Boolean;
      
      private var _layerManager:LayerManager;
      
      public var valueChangedCallback:Function;
      
      public function DebugGUISlider()
      {
         super();
      }
      
      public function init(param1:Object, param2:Function, param3:Boolean = false) : void
      {
         var initParent:Object = param1;
         var initValueChangedCallback:Function = param2;
         var initVisible:Boolean = param3;
         _layerManager = LayerManager(initParent);
         initParent = initParent.fps;
         _slider = new Sprite();
         _nub = new Sprite();
         with(_nub.graphics)
         {
            beginFill(NUB_COLOR);
            drawRect(-NUB_WIDTH * 0.5,-NUB_HEIGHT * 0.5,NUB_WIDTH,NUB_HEIGHT);
         }
         _nub.x = 120 * 1;
         _nub.y = 0;
         with(_slider.graphics)
         {
            lineStyle(2);
            moveTo(0,0);
            lineTo(SLIDER_WIDTH,0);
            beginFill(0,0);
            drawRect(-NUB_WIDTH,-NUB_HEIGHT,SLIDER_WIDTH + NUB_WIDTH + NUB_WIDTH,NUB_HEIGHT + NUB_HEIGHT);
         }
         _slider.x = 400;
         _slider.y = 200;
         gMainFrame.stage.addEventListener("keyDown",onKeyDown,false,0,true);
         _slider.addEventListener("mouseDown",sliderMouseDownHandler,false,0,true);
         _slider.addEventListener("mouseMove",sliderMouseMoveHandler,false,0,true);
         _slider.addEventListener("mouseOut",sliderMouseOutHandler,false,0,true);
         _slider.addEventListener("mouseUp",sliderMouseUpHandler,false,0,true);
         _slider.addChild(_nub);
         initParent.addChild(_slider);
         _value = new TextField();
         _value.x = 400 + 120 + 10 + 10 + 10;
         _value.y = _slider.y;
         _value.width = 32;
         _value.text = "1";
         initParent.addChild(_value);
         _visible = initVisible;
         _slider.visible = _visible;
         _value.visible = _visible;
         valueChangedCallback = initValueChangedCallback;
      }
      
      public function toggleVisiblity() : void
      {
         _nub.x = 120 * _layerManager.bkg.scaleX;
         _value.text = String(_layerManager.bkg.scaleX);
         _visible = !_visible;
         _slider.visible = _visible;
         _value.visible = _visible;
      }
      
      private function sliderMouseDownHandler(param1:MouseEvent) : void
      {
         _drag = true;
         sliderMouseMoveHandler(param1);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:Number = NaN;
         if(param1.keyCode == 107)
         {
            _nub.x += 1;
            _loc3_ = true;
         }
         else if(param1.keyCode == 109)
         {
            _nub.x -= 1;
            _loc3_ = true;
         }
         else if(param1.keyCode == 187)
         {
            _nub.x += 0.1;
            _loc3_ = true;
         }
         else if(param1.keyCode == 189)
         {
            _nub.x -= 0.1;
            _loc3_ = true;
         }
         if(_loc3_)
         {
            _loc2_ = _nub.x * 1 / 120;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _loc2_;
            _value.text = String(_loc2_);
         }
      }
      
      private function sliderMouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_drag && param1.target is DisplayObject && _slider.contains(DisplayObject(param1.target)))
         {
            param1.stopPropagation();
            _loc3_ = param1.localX;
            if(param1.target == _nub)
            {
               _loc3_ += _nub.x;
            }
            if(_loc3_ < 0)
            {
               _loc3_ = 0;
            }
            if(_loc3_ > 120)
            {
               _loc3_ = 120;
            }
            _nub.x = _loc3_;
            _loc2_ = _loc3_ * 1 / 120;
            _layerManager.bkg.scaleX = _layerManager.bkg.scaleY = _loc2_;
            _value.text = String(_loc2_);
         }
      }
      
      private function sliderMouseOutHandler(param1:MouseEvent) : void
      {
         if(!param1.relatedObject || !_slider.contains(param1.relatedObject))
         {
            _drag = false;
         }
      }
      
      private function sliderMouseUpHandler(param1:MouseEvent) : void
      {
         _drag = false;
      }
   }
}

