package gui.itemWindows
{
   public class ItemWindowPattern extends ItemWindowBase
   {
      public static const TYPE_SWATCH:String = "swatch";
      
      public static const TYPE_MESSAGE:String = "message";
      
      public static const TYPE_POST:String = "post";
      
      public static const TYPE_REPLY:String = "reply";
      
      private var _type:String;
      
      private var _patternIndexOrName:Object;
      
      private var _colorIndexOrName:Object;
      
      public function ItemWindowPattern(param1:Function, param2:Object, param3:String, param4:int, param5:Function, param6:Function, param7:Function, param8:Function, param9:Object)
      {
         _type = param9.type;
         _patternIndexOrName = param9.patternIndex != null ? param9.patternIndex : param4 + 1;
         _colorIndexOrName = param9.colorIndex != null ? param9.colorIndex : 1;
         super(param2,param1,param2,param3,param4,param5,param6,param7,param8,false);
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_window)
         {
            _window.gotoAndStop(_type);
            _window[_type + "Btn"].pattern.gotoAndStop(_patternIndexOrName);
            _window[_type + "Btn"].updateColor(_colorIndexOrName);
         }
      }
      
      public function getCurrentPatternIndex() : int
      {
         return _window[_type + "Btn"].pattern.currentFrame;
      }
      
      public function setPatternAndColor(param1:Object, param2:Object) : void
      {
         _colorIndexOrName = param2;
         _patternIndexOrName = param1;
         setChildrenAndInitialConditions();
      }
      
      public function setColor(param1:Object) : void
      {
         _colorIndexOrName = param1;
         setChildrenAndInitialConditions();
      }
      
      public function setPattern(param1:Object) : void
      {
         _patternIndexOrName = param1;
         setChildrenAndInitialConditions();
      }
   }
}

