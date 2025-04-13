package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class SBOkCancelPopup extends SBStandardPopup
   {
      private var _okCancelBtn:MovieClip;
      
      private var _cancelBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBOkCancelPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null, param6:Number = undefined, param7:Number = undefined)
      {
         _confirmCallback = param4;
         _passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc8_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var _loc9_:MovieClip = GETDEFINITIONBYNAME("okCancelPopupContent");
         _okCancelBtn = _loc9_.okCancelBtn;
         _cancelBtn = _loc9_.cancelBtn;
         _okCancelBtn.addEventListener("mouseDown",onOkCancelBtn,false,0,true);
         _cancelBtn.addEventListener("mouseDown",onOkCancelBtn,false,0,true);
         _resizeCallback = onResize;
         super(param1,param2,param3,_loc9_,_loc8_,true,true,false,false,"",param6,param7,NaN,NaN,null);
         stage.addEventListener("keyDown",handleBlockCancelKeyDown,false,0,true);
      }
      
      override public function destroy() : void
      {
         if(stage)
         {
            stage.removeEventListener("keyDown",handleBlockCancelKeyDown);
         }
         _okCancelBtn.removeEventListener("mouseDown",onOkCancelBtn);
         _cancelBtn.removeEventListener("mouseDown",onOkCancelBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         _okCancelBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         _cancelBtn.y = _okCancelBtn.y;
      }
      
      private function handleBlockCancelKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               param1.stopPropagation();
               handleOkCancel(true);
               break;
            case 8:
            case 46:
            case 27:
               param1.stopPropagation();
               handleOkCancel(false);
         }
      }
      
      private function onOkCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handleOkCancel(param1.currentTarget == _okCancelBtn);
      }
      
      private function handleOkCancel(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         destroy();
         if(_confirmCallback != null)
         {
            _loc2_ = {
               "status":param1,
               "passback":_passbackObject
            };
            _confirmCallback(_loc2_);
         }
      }
   }
}

