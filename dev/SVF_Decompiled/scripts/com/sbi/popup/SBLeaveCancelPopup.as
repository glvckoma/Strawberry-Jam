package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class SBLeaveCancelPopup extends SBStandardPopup
   {
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      private var _leaveBtn:Object;
      
      private var _cancelBtn:Object;
      
      public function SBLeaveCancelPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null)
      {
         _confirmCallback = param4;
         _passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc6_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var _loc7_:MovieClip = GETDEFINITIONBYNAME("LeaveCancelPopupContent");
         _resizeCallback = onResize;
         _leaveBtn = _loc7_.leaveBtn;
         _cancelBtn = _loc7_.cancelBtn;
         _leaveBtn.addEventListener("mouseDown",onLeaveCancelBtn,false,0,true);
         _cancelBtn.addEventListener("mouseDown",onLeaveCancelBtn,false,0,true);
         super(param1,param2,param3,_loc7_,_loc6_);
         stage.addEventListener("keyDown",handleLeaveCancelKeyDown,false,0,true);
      }
      
      override public function destroy() : void
      {
         if(stage)
         {
            stage.removeEventListener("keyDown",handleLeaveCancelKeyDown);
         }
         _leaveBtn.removeEventListener("mouseDown",onLeaveCancelBtn);
         _cancelBtn.removeEventListener("mouseDown",onLeaveCancelBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         _leaveBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         _cancelBtn.y = _leaveBtn.y;
      }
      
      private function handleLeaveCancelKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               param1.stopPropagation();
               handleLeaveCancel(true);
               break;
            case 8:
            case 46:
            case 27:
               param1.stopPropagation();
               handleLeaveCancel(false);
         }
      }
      
      private function onLeaveCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handleLeaveCancel(param1.currentTarget == _leaveBtn);
      }
      
      private function handleLeaveCancel(param1:Boolean) : void
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

