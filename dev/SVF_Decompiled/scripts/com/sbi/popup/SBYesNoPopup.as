package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.net.FileReference;
   
   public dynamic class SBYesNoPopup extends SBStandardPopup
   {
      private var _yesBtn:MovieClip;
      
      private var _noBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBYesNoPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null, param6:Boolean = true, param7:Boolean = true, param8:Boolean = false, param9:Boolean = false, param10:String = null, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Array = null)
      {
         _confirmCallback = param4;
         _passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc16_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var _loc17_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupContent");
         _yesBtn = _loc17_.yesBtn;
         _noBtn = _loc17_.noBtn;
         _yesBtn.addEventListener("mouseDown",onYesNoBtn,false,0,true);
         _noBtn.addEventListener("mouseDown",onYesNoBtn,false,0,true);
         _resizeCallback = onResize;
         super(param1,param2,param3,_loc17_,_loc16_,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15);
         stage.addEventListener("keyDown",handleYesNoKeyDown,false,0,true);
      }
      
      override public function destroy() : void
      {
         if(stage)
         {
            stage.removeEventListener("keyDown",handleYesNoKeyDown);
         }
         _yesBtn.removeEventListener("mouseDown",onYesNoBtn);
         _noBtn.removeEventListener("mouseDown",onYesNoBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         _yesBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         _noBtn.y = _yesBtn.y;
      }
      
      private function handleYesNoKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               param1.stopPropagation();
               handleYesNo(true);
               break;
            case 8:
            case 46:
            case 27:
               param1.stopPropagation();
               handleYesNo(false);
         }
      }
      
      private function onYesNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handleYesNo(param1.currentTarget == _yesBtn);
      }
      
      private function handleYesNo(param1:Boolean) : void
      {
         var _loc2_:FileReference = null;
         var _loc3_:Object = null;
         destroy();
         if(param1 && _passbackObject && _passbackObject.hasOwnProperty("FileReference"))
         {
            _loc2_ = new FileReference();
            _loc2_.save(_passbackObject.ImageData,_passbackObject.SaveName);
         }
         if(_confirmCallback != null)
         {
            _loc3_ = {
               "status":param1,
               "passback":_passbackObject
            };
            _confirmCallback(_loc3_);
         }
      }
   }
}

