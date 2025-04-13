package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public dynamic class SBBlockCancelPopup extends SBStandardPopup
   {
      private var _blockUnblockBtn:MovieClip;
      
      private var _cancelBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBBlockCancelPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null, param6:Number = undefined, param7:Number = undefined)
      {
         _confirmCallback = param4;
         _passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc8_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var _loc9_:MovieClip = GETDEFINITIONBYNAME("blockCancelPopupContent");
         _blockUnblockBtn = _loc9_.blockUnblockBtn;
         _cancelBtn = _loc9_.cancelBtn;
         _blockUnblockBtn.addEventListener("mouseDown",onBlockCancelBtn,false,0,true);
         _cancelBtn.addEventListener("mouseDown",onBlockCancelBtn,false,0,true);
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
         _blockUnblockBtn.removeEventListener("mouseDown",onBlockCancelBtn);
         _cancelBtn.removeEventListener("mouseDown",onBlockCancelBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         _blockUnblockBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         _cancelBtn.y = _blockUnblockBtn.y;
      }
      
      private function handleBlockCancelKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               param1.stopPropagation();
               handleBlockCancel(true);
               break;
            case 8:
            case 46:
            case 27:
               param1.stopPropagation();
               handleBlockCancel(false);
         }
      }
      
      private function onBlockCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handleBlockCancel(param1.currentTarget == _blockUnblockBtn);
      }
      
      private function handleBlockCancel(param1:Boolean) : void
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

