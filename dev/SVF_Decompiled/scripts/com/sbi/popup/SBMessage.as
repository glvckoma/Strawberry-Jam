package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class SBMessage extends SBPopup
   {
      public var messageTxt:TextField = new TextField();
      
      public function SBMessage(param1:DisplayObjectContainer, param2:MovieClip, param3:String, param4:Boolean = true, param5:Boolean = true, param6:Boolean = false, param7:Boolean = true, param8:Boolean = false, param9:String = null, param10:Number = undefined, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Array = null)
      {
         messageTxt.text = param3;
         super(param1,param2,messageTxt,param4,param5,param6,param7,param8,param9,param10,param11,param12,param13,param14);
      }
   }
}

