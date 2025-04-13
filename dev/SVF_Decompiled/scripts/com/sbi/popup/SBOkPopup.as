package com.sbi.popup
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   
   public dynamic class SBOkPopup extends SBStandardPopup
   {
      private var _okBtn:MovieClip;
      
      private var _okBtnCallback:Function;
      
      public function SBOkPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Boolean = true, param6:Boolean = true, param7:Boolean = false, param8:Boolean = false, param9:String = null, param10:Number = undefined, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Array = null)
      {
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         if(param4 != null)
         {
            _okBtnCallback = param4;
         }
         else
         {
            _okBtnCallback = onOkBtn;
         }
         var _loc15_:MovieClip = GETDEFINITIONBYNAME("OkPopupSkin");
         var _loc16_:MovieClip = GETDEFINITIONBYNAME("OkPopupContent");
         _okBtn = _loc16_.okBtn;
         _okBtn.addEventListener("mouseDown",_okBtnCallback,false,0,true);
         _resizeCallback = onResize;
         super(param1,param2,param3,_loc16_,_loc15_,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14);
         stage.addEventListener("keyDown",handleOkKeyDown,false,0,true);
      }
      
      public static function destroyInParentChain(param1:DisplayObject) : void
      {
         while(param1 && param1 != gMainFrame.stage && !(param1 is SBOkPopup))
         {
            param1 = param1.parent;
         }
         if(param1 is SBOkPopup)
         {
            SBOkPopup(param1).destroy();
         }
      }
      
      override public function destroy() : void
      {
         _okBtn.removeEventListener("mouseDown",_okBtnCallback);
         if(stage != null)
         {
            stage.removeEventListener("keyDown",handleOkKeyDown);
         }
         super.destroy();
      }
      
      private function onResize() : void
      {
         _okBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
      }
      
      private function handleOkKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onOkBtn(param1);
         }
      }
      
      private function onOkBtn(param1:Event) : void
      {
         param1.stopPropagation();
         destroy();
      }
   }
}

